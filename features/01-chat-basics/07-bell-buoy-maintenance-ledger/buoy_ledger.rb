# frozen_string_literal: true

# Chat basics · 07 · Bell buoy maintenance ledger
#
# Teaches:
# - say is the alias of ask. The ledger uses say for both turns.
# - chat.messages is the transcript, and each entry has a role and content.
# - A follow-up say sends the earlier ledger lines back.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module EdizHookBellBuoy
  # The buoy tender reads the Ediz Hook ledger out loud, one question
  # at a time, and keeps the transcript on the same chat.
  class BuoyLedger
    INSTRUCTIONS = <<~TEXT.strip
      You are the buoy tender working the Ediz Hook bell buoy.
      Answer in two short sentences.
      Use only the ledger in this chat.
      Quote dates and the voltage as printed.
      Do not invent haul dates or voltages.
    TEXT

    CLAPPER_QUESTION = <<~TEXT.strip
      Maintenance ledger for the lighted bell buoy off Ediz Hook.
      The tender checks the name against the light list at https://www.navcen.uscg.gov/.
      Last painted: 12 March 2026, red.
      Clapper: replaced 2 April 2026.
      Battery this morning: 11.8 volts.
      Next haul: 3 November 2026.
      What is the clapper date, and what is the battery voltage?
    TEXT

    HAUL_QUESTION = "When is the next haul? Keep the battery voltage in the answer."

    Result = Struct.new(
      :clapper,
      :haul,
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

      clapper = chat.say(CLAPPER_QUESTION)
      haul = chat.say(HAUL_QUESTION)

      Result.new(
        clapper: clapper.content,
        haul: haul.content,
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
  Multivitamin::Cassettes.play(__dir__, "buoy_ledger") do
    result = EdizHookBellBuoy::BuoyLedger.conduct
  end

  result.transcript.each do |role, text|
    puts "#{role}: #{text}"
    puts
  end
end
