# frozen_string_literal: true

# Agents · 05 · Friday Harbor berth fallbacks
#
# Teaches:
# - fallbacks on an Agent is with_fallbacks on every chat it builds.
# - DEFAULT_ERRORS does not include BadRequestError, so a 400 stays.
# - on: [BadRequestError] lets that 400 hop to gpt-4.1-mini.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module FridayHarborBerthFallbacks
  UNLISTED = "friday-harbor-berth-unlisted"

  class BerthClerk < RubyLLM::Agent
    model UNLISTED, provider: :openrouter, assume_model_exists: true
    temperature 0.2

    instructions <<~TEXT.strip
      You are the berth clerk at Friday Harbor.
      Answer in two short sentences from the slip sheet only.
      Name slip 14 and the Kalakala.
      Do not invent a beam.
    TEXT
  end

  class SlipSheet
    BERTH_QUESTION = <<~TEXT.strip
      Friday Harbor slip sheet, Wednesday 15 October 2026.
      Harbor: https://www.portfridayharbor.org/
      The Kalakala is assigned slip 14, 40-foot beam.
      Which slip does the Kalakala take?
    TEXT

    Result = Struct.new(
      :default_error,
      :default_status,
      :rescued,
      :fallback_model,
      :roles,
      keyword_init: true
    )

    Attempt = Struct.new(:error, :message, :roles, keyword_init: true)

    def self.conduct
      configure
      spare = RubyLLM.models.find(Multivitamin::Models::OPENAI_CHAT, provider: :openai)

      default_error = ask_with_fallbacks(spare)
      rescued = ask_with_fallbacks(spare, on: [RubyLLM::BadRequestError])

      Result.new(
        default_error: default_error.error,
        default_status: default_error.error&.response&.status,
        rescued: rescued.message&.content,
        fallback_model: rescued.message&.model,
        roles: rescued.roles
      )
    end

    def self.ask_with_fallbacks(spare, on: nil)
      BerthClerk.fallbacks(spare, **(on ? { on: on } : {}))
      agent = BerthClerk.new
      message = agent.ask(BERTH_QUESTION)
      Attempt.new(error: nil, message: message, roles: agent.messages.map(&:role))
    rescue RubyLLM::Error => error
      Attempt.new(error: error, message: nil, roles: agent.messages.map(&:role))
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
  Multivitamin::Cassettes.play(__dir__, "berth_fallbacks") do
    result = FridayHarborBerthFallbacks::SlipSheet.conduct
  end

  puts "#{result.default_error.class} #{result.default_status}"
  puts result.rescued
end
