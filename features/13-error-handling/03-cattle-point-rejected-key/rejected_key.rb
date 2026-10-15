# frozen_string_literal: true

# Error handling · 03 · Cattle Point rejected key
#
# Teaches:
# - A rejected OpenRouter key is HTTP 401 and UnauthorizedError.
# - Error#response is the Faraday response. Status is 401.
# - request_shape describes the refused turn without the prompt text.
# - UnauthorizedError inherits RubyLLM::Error.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module CattlePointRejectedKey
  # The Cattle Point radio, on the southeast tip of San Juan Island, still
  # has last winter's OpenRouter key. The provider refuses it. The kelp
  # watch question never comes back as a brief.
  class RejectedKey
    REJECTED = "sk-or-v1-cattle-point-rejected-watch-key"

    INSTRUCTIONS = <<~TEXT.strip
      You are the kelp watch at Cattle Point Light on San Juan Island.
      Answer in two short sentences.
      Use only the kelp ledger in the question.
      Name Salmon Bank and 2.4 knots.
    TEXT

    LEDGER_QUESTION = <<~TEXT.strip
      Kelp ledger posted at Cattle Point, Thursday 15 October 2026.
      Light station notes: https://www.nps.gov/sajh/.
      Ebb past Salmon Bank 2.4 knots at 07:20.
      Bull kelp on the reef south of the light, do not cut inside.
      When is the ebb at Salmon Bank?
    TEXT

    Result = Struct.new(
      :error,
      :status,
      :shape,
      :shape_hash,
      :is_llm_error,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = RubyLLM.chat(
        model: Multivitamin::Models::CHAT,
        provider: :openrouter,
        assume_model_exists: true
      )
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)

      error = nil
      begin
        chat.ask(LEDGER_QUESTION)
      rescue RubyLLM::Error => raised
        error = raised
      end

      Result.new(
        error: error,
        status: error&.response&.status,
        shape: error&.request_shape,
        shape_hash: error&.request_shape&.to_h,
        is_llm_error: error.is_a?(RubyLLM::Error)
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        config.openrouter_api_key = REJECTED
        config.openrouter_app_url = "https://github.com/mikeymicrophone/rubyllm-multivitamin"
        config.openrouter_app_name = "RubyLLM Multivitamin"
        config.openai_use_system_role = true
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
  Multivitamin::Cassettes.play(__dir__, "rejected_key") do
    result = CattlePointRejectedKey::RejectedKey.conduct
  end

  puts "#{result.error.class} #{result.status}"
  puts result.error.message
  puts result.shape
end
