# frozen_string_literal: true

# Models and providers · 03 · Lime Kiln whale-watch radio alias
#
# Teaches:
# - The same alias resolves to different ids on anthropic and bedrock.
# - find without a provider prefers the first-party anthropic entry, and
#   that entry's id can be the short name rather than the dated alias.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"

module LimeKilnWhaleWatch
  # The skipper off Lime Kiln Point calls the same Haiku alias on two radio
  # channels, the way a whale-watch boat names one orca and gets a different
  # NOAA catalog id from each dispatcher.
  class HaikuAlias
    Result = Struct.new(
      :bare_id,
      :bare_provider,
      :anthropic_id,
      :anthropic_provider,
      :anthropic_family,
      :anthropic_window,
      :bedrock_id,
      :bedrock_provider,
      :bedrock_family,
      :bedrock_window,
      keyword_init: true
    )

    ALIAS = "claude-haiku-4-5"

    def self.conduct
      configure

      bare = RubyLLM.models.find(ALIAS)
      anthropic = RubyLLM.models.find(ALIAS, provider: :anthropic)
      bedrock = RubyLLM.models.find(ALIAS, provider: :bedrock)

      Result.new(
        bare_id: bare.id,
        bare_provider: bare.provider,
        anthropic_id: anthropic.id,
        anthropic_provider: anthropic.provider,
        anthropic_family: anthropic.family,
        anthropic_window: anthropic.context_window,
        bedrock_id: bedrock.id,
        bedrock_provider: bedrock.provider,
        bedrock_family: bedrock.family,
        bedrock_window: bedrock.context_window
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        config.max_retries = 0
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "haiku_alias") do
    result = LimeKilnWhaleWatch::HaikuAlias.conduct
  end

  puts "bare #{result.bare_provider} #{result.bare_id}"
  puts "anthropic #{result.anthropic_id}"
  puts "bedrock #{result.bedrock_id}"
end
