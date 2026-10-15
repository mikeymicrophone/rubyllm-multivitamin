# frozen_string_literal: true

# Agents · 09 · Bremerton sill rescue
#
# Teaches:
# - rescue_from handles errors from ask on the agent instance.
# - Without a raise in the handler, the handler's return value is the result.
# - Agent.chat returns a Chat, so the same 400 still leaves the desk.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module BremertonSillRescue
  UNLISTED = "bremerton-sill-unlisted"

  class SillClerk < RubyLLM::Agent
    model UNLISTED, provider: :openrouter, assume_model_exists: true
    temperature 0.2

    instructions <<~TEXT.strip
      You are the dry dock clerk at Bremerton.
      Answer in one short sentence from the sill card only.
      Name 4.2 fathoms.
    TEXT

    rescue_from RubyLLM::BadRequestError do |error|
      "The dry dock desk posts the sill as 4.2 fathoms after #{error.class}."
    end
  end

  class SillCard
    CARD_QUESTION = <<~TEXT.strip
      Bremerton dry dock sill card, Wednesday 15 October 2026.
      Yard notes: https://www.navsea.navy.mil/
      Posted sill 4.2 fathoms at high water.
      What sill does the incoming watch post?
    TEXT

    Result = Struct.new(
      :rescued,
      :chat_error_class,
      :chat_status,
      :chat_class,
      :instance_class,
      keyword_init: true
    )

    def self.conduct
      configure
      instance = SillClerk.new
      rescued = instance.ask(CARD_QUESTION)

      chat_error_class = nil
      chat_status = nil
      begin
        SillClerk.chat.ask(CARD_QUESTION)
      rescue RubyLLM::BadRequestError => error
        chat_error_class = error.class.name
        chat_status = error.response&.status
      end

      Result.new(
        rescued: rescued,
        chat_error_class: chat_error_class,
        chat_status: chat_status,
        chat_class: SillClerk.chat.class.name,
        instance_class: instance.class.name
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        config.openrouter_api_key = Multivitamin::Models.api_key("OPENROUTER_API_KEY")
        config.openrouter_app_url = "https://github.com/mikeymicrophone/rubyllm-multivitamin"
        config.openrouter_app_name = "RubyLLM Multivitamin"
        config.openai_use_system_role = true
        config.max_retries = 0
        config.request_timeout = 90
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "sill_rescue") do
    result = BremertonSillRescue::SillCard.conduct
  end

  puts result.rescued
  puts result.chat_error_class
end
