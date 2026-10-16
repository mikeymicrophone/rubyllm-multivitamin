# frozen_string_literal: true

# Configuration and contexts · 12 · Nouakchott clinic spare radio
#
# Teaches:
# - A context that clears the provider key raises ConfigurationError
#   before any HTTP call.
# - ConfigurationError inherits StandardError, not RubyLLM::Error.
# - The global chat still works on the configured key.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../paid_openrouter"

module NouakchottClinicRadio
  # The spare radio on the Nouakchott desert-clinic trolley has no
  # OpenRouter key. The working radio still reads the saline ledger.
  class EmptyContext
    INSTRUCTIONS = <<~TEXT.strip
      You are the ward clerk at the desert clinic on the edge of Nouakchott.
      Answer in two short sentences.
      Use only the ledger in the question.
      Quote 11.8 litres.
      Do not invent a haul date.
    TEXT

    LEDGER_QUESTION = <<~TEXT.strip
      Saline ledger for the Nouakchott desert clinic, Wednesday 14 October 2026.
      Ministry page: https://www.sante.gov.mr/.
      Last restocked: 12 March 2026, Ringer's and normal saline.
      Saline remaining this morning: 11.8 litres on the ward trolley.
      Next truck: 3 November 2026.
      What is the remaining saline?
    TEXT

    Result = Struct.new(
      :empty_error_class,
      :empty_error_message,
      :empty_is_llm_error,
      :ledger,
      keyword_init: true
    )

    def self.conduct
      configure
      args = ConfigurationPaidOpenrouter.chat_args
      empty = RubyLLM.context do |config|
        config.openrouter_api_key = nil
        config.openai_api_key = nil
      end

      empty_error_class = nil
      empty_error_message = nil
      empty_is_llm_error = nil
      begin
        empty.chat(**args)
      rescue StandardError => error
        empty_error_class = error.class
        empty_error_message = error.message
        empty_is_llm_error = error.is_a?(RubyLLM::Error)
      end

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      ledger = chat.ask(LEDGER_QUESTION)

      Result.new(
        empty_error_class: empty_error_class,
        empty_error_message: empty_error_message,
        empty_is_llm_error: empty_is_llm_error,
        ledger: ledger.content
      )
    end

    def self.open_chat
      ConfigurationPaidOpenrouter.prepare(
        RubyLLM.chat(**ConfigurationPaidOpenrouter.chat_args)
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openrouter)
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
  Multivitamin::Cassettes.play(__dir__, "empty_context") do
    result = NouakchottClinicRadio::EmptyContext.conduct
  end

  puts result.empty_error_class
  puts result.empty_error_message
  puts
  puts result.ledger
end
