# frozen_string_literal: true

# Models and providers · 10 · AlUla inscription-list refresh
#
# Teaches:
# - refresh downloads the published catalog. It is a network call.
# - The in-memory registry is replaced, then this scenario restores the
#   bundled snapshot so later examples keep a stable board.
# - A missing model is not recovered by guessing; refresh is explicit.

require "fileutils"
require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"

module AlulaInscription
  # The inscription desk at AlUla pulls a fresh Dadanitic catalog from
  # the published list instead of working off last month's paper.
  class Refresh
    REGISTRY_FILE = File.expand_path("../../../tmp/alula_inscription_list.json", __dir__)

    Result = Struct.new(
      :before_count,
      :after_count,
      :mini_id,
      :mini_provider,
      :wrote_registry,
      keyword_init: true
    )

    def self.conduct
      configure
      clear_local_list

      before_count = RubyLLM.models.all.size
      begin
        RubyLLM.models.refresh(remote_only: true)
        mini = RubyLLM.models.find("gpt-4.1-mini")

        Result.new(
          before_count: before_count,
          after_count: RubyLLM.models.all.size,
          mini_id: mini.id,
          mini_provider: mini.provider,
          wrote_registry: File.file?(REGISTRY_FILE)
        )
      ensure
        RubyLLM.models.load_from_json(RubyLLM::Models.bundled_registry_file)
      end
    end

    def self.clear_local_list
      FileUtils.mkdir_p(File.dirname(REGISTRY_FILE))
      FileUtils.rm_f(REGISTRY_FILE)
      FileUtils.rm_f("#{REGISTRY_FILE}.etag")
      FileUtils.rm_f("#{REGISTRY_FILE}.published.json")
    end

    def self.configure
      RubyLLM.configure do |config|
        config.max_retries = 0
        config.request_timeout = 120
        config.model_registry_file = REGISTRY_FILE
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "inscription_refresh") do
    result = AlulaInscription::Refresh.conduct
  end

  puts "before #{result.before_count} after #{result.after_count}"
  puts "#{result.mini_provider} #{result.mini_id}"
end
