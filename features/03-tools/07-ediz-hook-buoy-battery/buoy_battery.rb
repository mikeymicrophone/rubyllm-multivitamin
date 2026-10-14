# frozen_string_literal: true

# Tools · 07 · Ediz Hook buoy battery
#
# Teaches:
# - A miss returns { error: }. That hash is JSON on the tool message,
#   and the model can call the tool again.
# - choice: :required is cleared after the tool runs, so the second call
#   is the model's own.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module EdizHookBuoyBattery
  class BuoyBattery < RubyLLM::Tool
    description "Reads the battery card for a bell buoy on the Ediz Hook ledger"

    def self.tool_name
      "buoy_battery"
    end

    parameter :buoy, type: :string, description: "Buoy name on the ledger, such as LL-4", required: true

    CARDS = {
      "LL-4" => "LL-4 battery 12.6 V at Ediz Hook, read Wednesday 14 October 2026."
    }.freeze

    def execute(buoy:)
      card = CARDS[buoy.to_s.upcase]
      return card if card

      { error: "#{buoy} is not on the Ediz Hook ledger. Call buoy_battery again with buoy LL-4." }
    end
  end

  class BatteryRound
    INSTRUCTIONS = <<~TEXT.strip
      You are the buoy tender at Ediz Hook.
      Call buoy_battery with the buoy the watch named.
      If the tool returns an error, call buoy_battery again with the buoy the error names.
      Then answer in one sentence that includes the voltage from the card.
    TEXT

    BATTERY_QUESTION = <<~TEXT.strip
      Wednesday 14 October 2026, battery round off Ediz Hook.
      Light list: https://www.navcen.uscg.gov/
      The watch asked for the battery on buoy LL-17.
      Read the card and report the voltage.
    TEXT

    Result = Struct.new(:answer, :roles, :tool_contents, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.with_thinking(false)
      chat.with_tools(BuoyBattery)
      chat.with_tool_options(choice: :required)

      answer = chat.ask(BATTERY_QUESTION)

      Result.new(
        answer: answer.content,
        roles: chat.messages.map(&:role),
        tool_contents: chat.messages.select { |message| message.role == :tool }.map(&:content)
      )
    end

    def self.open_chat
      RubyLLM.chat(
        model: Multivitamin::Models::CHAT,
        provider: :openrouter,
        assume_model_exists: true
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
        config.request_timeout = 180
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "buoy_battery") do
    result = EdizHookBuoyBattery::BatteryRound.conduct
  end

  puts result.answer
end
