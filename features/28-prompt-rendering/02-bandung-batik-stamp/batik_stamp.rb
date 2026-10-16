# frozen_string_literal: true

# Prompt rendering · 02 · Bandung batik stamp
#
# Teaches:
# - render_prompt raises PromptNotFoundError when the .txt.erb is absent.
# - PromptNotFoundError inherits StandardError, not RubyLLM::Error.
# - There is no cassette file.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/prompts"

module BandungBatikStamp
  class BatikStamp
    Result = Struct.new(:error, :message, :superclass, :caught_as_provider, keyword_init: true)

    def self.conduct
      configure
      error = nil
      caught_as_provider = false
      Multivitamin::Prompts.in_root(__dir__) do
        begin
          RubyLLM.render_prompt("batik/missing_canting")
        rescue RubyLLM::Error
          caught_as_provider = true
        rescue RubyLLM::PromptNotFoundError => raised
          error = raised
        end
      end
      Result.new(
        error: error,
        message: error&.message,
        superclass: error&.class&.superclass&.name,
        caught_as_provider: caught_as_provider
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 120
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end

  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "batik_stamp") do
    result = BandungBatikStamp::BatikStamp.conduct
  end

  puts result.error.class
  puts result.message
end
