# frozen_string_literal: true

# Error handling · 06 · Hein Bank model fallback
#
# Teaches:
# - with_fallbacks tries the next model only for errors in on:.
# - DEFAULT_ERRORS does not include BadRequestError, so a 400 on an
#   unlisted slug stays on the desk.
# - on: [BadRequestError] lets the same 400 fall through to gpt-4.1-mini.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module HeinBankModelFallback
  # The sounding desk over Hein Bank, south of San Juan Island, first
  # aims at a slug the registry never listed. The default fallback list
  # does not treat that 400 as transient. Naming BadRequestError on the
  # second chat lets the brief reach OpenAI.
  class ShoalFallback
    UNLISTED = "hein-bank-shoal-unlisted"

    INSTRUCTIONS = <<~TEXT.strip
      You are the sounding clerk over Hein Bank, south of San Juan Island.
      Answer in two short sentences.
      Use only the cast in the question.
      Name 8 fathoms and the ebb.
    TEXT

    CAST_QUESTION = <<~TEXT.strip
      Sounding cast over Hein Bank, Thursday 15 October 2026.
      Chart catalog: https://www.nauticalcharts.noaa.gov/.
      Least depth 8 fathoms, sand and shell.
      Ebb 1.6 knots, setting west.
      What is the least depth, and which way does the ebb set?
    TEXT

    Result = Struct.new(
      :default_error,
      :default_status,
      :rescued,
      :roles,
      :fallback_model,
      keyword_init: true
    )

    def self.conduct
      configure
      spare = RubyLLM.models.find(Multivitamin::Models::OPENAI_CHAT, provider: :openai)

      default_error = ask_with_fallbacks(spare)
      rescued = ask_with_fallbacks(spare, on: [RubyLLM::BadRequestError])

      Result.new(
        default_error: default_error.error,
        default_status: default_error.error&.response&.status,
        rescued: rescued.message&.content,
        roles: rescued.roles,
        fallback_model: rescued.message&.model
      )
    end

    Attempt = Struct.new(:error, :message, :roles, keyword_init: true)

    def self.ask_with_fallbacks(spare, on: nil)
      chat = RubyLLM.chat(
        model: UNLISTED,
        provider: :openrouter,
        assume_model_exists: true
      )
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      if on
        chat.with_fallbacks(spare, on: on)
      else
        chat.with_fallbacks(spare)
      end

      message = chat.ask(CAST_QUESTION)
      Attempt.new(error: nil, message: message, roles: chat.messages.map(&:role))
    rescue RubyLLM::Error => error
      Attempt.new(error: error, message: nil, roles: chat.messages.map(&:role))
    end

    def self.configure
      RubyLLM.configure do |config|
        config.openrouter_api_key = Multivitamin::Models.api_key("OPENROUTER_API_KEY")
        config.openai_api_key = Multivitamin::Models.api_key("OPENAI_API_KEY")
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
  Multivitamin::Cassettes.play(__dir__, "shoal_fallback") do
    result = HeinBankModelFallback::ShoalFallback.conduct
  end

  puts "#{result.default_error.class} #{result.default_status}"
  puts result.rescued
end
