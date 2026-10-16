# frozen_string_literal: true

# Prompt rendering · 08 · Mbarara ankole hide
#
# Teaches:
# - instructions { prompt("instructions") } requires the conventional file.
# - Agent.new raises PromptNotFoundError when that file is absent.
# - There is no cassette file.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/prompts"

module MbararaAnkoleHide
  class HideClerk < RubyLLM::Agent
    model Multivitamin::Models::OPENAI_CHAT, provider: :openai
    instructions { prompt("instructions") }
  end

  class AnkoleHide
    Result = Struct.new(:error, :message, keyword_init: true)

    def self.conduct
      configure
      error = nil
      Multivitamin::Prompts.in_root(__dir__) do
        begin
          chosen = Multivitamin::Models.chat(provider: :openai)
          kwargs = { provider: chosen[:provider] }
          kwargs[:assume_model_exists] = true if chosen[:assume_model_exists]
          HideClerk.new(model: chosen[:model], **kwargs)
        rescue RubyLLM::PromptNotFoundError => raised
          error = raised
        end
      end
      Result.new(error: error, message: error&.message)
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
  Multivitamin::Cassettes.play(__dir__, "ankole_hide") do
    result = MbararaAnkoleHide::AnkoleHide.conduct
  end

  puts result.error.class
  puts result.message
end
