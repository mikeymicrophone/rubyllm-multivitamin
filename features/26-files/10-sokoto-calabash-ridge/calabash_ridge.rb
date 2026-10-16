# frozen_string_literal: true

# Files · 10 · Sokoto calabash ridge
#
# Teaches:
# - OpenAI requires purpose:. Omitting it is an HTTP 400, not a local
#   ArgumentError.
# - Vertex gs:// needs a project this catalog does not have.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module SokotoCalabashRidge
  class CalabashRidge
    NOTE = File.expand_path("ridge-note.txt", __dir__)

    Result = Struct.new(:error, keyword_init: true)

    def self.conduct
      configure

      error = nil
      begin
        RubyLLM.upload(NOTE, provider: :openai)
      rescue RubyLLM::Error => raised
        error = raised
      end

      Result.new(error: error)
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 60
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "calabash_ridge") do
    result = SokotoCalabashRidge::CalabashRidge.conduct
  end

  puts result.error.class
  puts result.error.message
end
