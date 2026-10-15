# frozen_string_literal: true

# Chat basics · 07 · Buenos Aires bandoneón ledger
#
# Teaches:
# - say is the alias of ask. The ledger uses say for both turns.
# - chat.messages is the transcript, and each entry has a role and content.
# - A follow-up say sends the earlier ledger lines back.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module BuenosAiresBandoneon
  # The reed technician reads the orquesta ledger out loud, one question
  # at a time, and keeps the transcript on the same chat.
  class BandoneonLedger
    INSTRUCTIONS = <<~TEXT.strip
      You are the reed technician for Orquesta Típica Rivarola in Buenos Aires.
      Answer in two short sentences.
      Use only the ledger in this chat.
      Quote dates and the pressure as printed.
      Do not invent overhaul dates or pressures.
    TEXT

    REED_QUESTION = <<~TEXT.strip
      Maintenance ledger for Pichuco's spare bandoneón at the orquesta loft on Calle Suipacha.
      The technician checks the serial against the orquesta archive at https://www.todotango.com/.
      Last restrung: 12 March 2026, yellow-box Premier.
      Reed plate: replaced 2 April 2026.
      Bellows this morning: 11.8 kPa.
      Next overhaul: 3 November 2026.
      What is the reed-plate date, and what is the bellows pressure?
    TEXT

    OVERHAUL_QUESTION = "When is the next overhaul? Keep the bellows pressure in the answer."

    Result = Struct.new(
      :reed,
      :overhaul,
      :roles,
      :transcript,
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

      reed = chat.say(REED_QUESTION)
      overhaul = chat.say(OVERHAUL_QUESTION)

      Result.new(
        reed: reed.content,
        overhaul: overhaul.content,
        roles: chat.messages.map(&:role),
        transcript: chat.messages.map { |message| [message.role, message.content] }
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        config.openrouter_api_key = ENV.fetch("OPENROUTER_API_KEY")
        config.openrouter_app_url = "https://github.com/mikeymicrophone/rubyllm-multivitamin"
        config.openrouter_app_name = "RubyLLM Multivitamin"
        # Chat Completions emits a developer role unless this is set.
        # OpenRouter expects system. The flag is shared with OpenAI's formatter.
        config.openai_use_system_role = true
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
  Multivitamin::Cassettes.play(__dir__, "bandoneon_ledger") do
    result = BuenosAiresBandoneon::BandoneonLedger.conduct
  end

  result.transcript.each do |role, text|
    puts "#{role}: #{text}"
    puts
  end
end
