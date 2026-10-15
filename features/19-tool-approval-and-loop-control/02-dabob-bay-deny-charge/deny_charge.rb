# frozen_string_literal: true

# Tool approval and loop control · 02 · Dabob Bay deny the charge
#
# Teaches:
# - deny records a refusal. execute never runs.
# - complete appends a structured denial result and asks the model to
#   continue from there.

require "json"
require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module DabobBayDenyCharge
  class FireRangeCharge < RubyLLM::Tool
    description "Fires a SUS hydrophone charge at a Dabob Bay range buoy. Needs the range officer's latch."

    def self.tool_name
      "fire_range_charge"
    end

    requires_approval

    parameter :buoy, type: :string, description: "Range buoy, such as DB-7", required: true

    def self.reset!
      @fired = false
    end

    def self.fired?
      @fired == true
    end

    def execute(buoy:)
      self.class.instance_variable_set(:@fired, true)
      "Fired a 2 lb SUS charge at Dabob Bay buoy #{buoy}."
    end
  end

  class RangeOfficer
    INSTRUCTIONS = <<~TEXT.strip
      You are the range officer on Dabob Bay.
      Call fire_range_charge with buoy DB-7.
      If the tool is denied, answer in one short sentence that the charge
      was not fired at buoy DB-7. Do not invent a blast.
    TEXT

    CHARGE_QUESTION = <<~TEXT.strip
      Thursday 15 October 2026, acoustic range on Dabob Bay.
      Range notes: https://www.navcen.uscg.gov/
      Fire the hydrophone charge at buoy DB-7.
    TEXT

    Result = Struct.new(
      :awaiting,
      :fired,
      :denial,
      :answer,
      :roles,
      keyword_init: true
    )

    def self.conduct
      configure
      FireRangeCharge.reset!

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_tools(FireRangeCharge)
      chat.with_tool_options(choice: FireRangeCharge)

      chat.ask(CHARGE_QUESTION)
      awaiting = chat.awaiting_approval?
      pending = chat.pending_approvals.first
      chat.deny(pending) if pending
      answer = chat.complete
      tool_message = chat.messages.find { |message| message.role == :tool }

      Result.new(
        awaiting: awaiting,
        fired: FireRangeCharge.fired?,
        denial: tool_message&.content,
        answer: answer&.content,
        roles: chat.messages.map(&:role)
      )
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
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
  Multivitamin::Cassettes.play(__dir__, "deny_charge") do
    result = DabobBayDenyCharge::RangeOfficer.conduct
  end

  puts result.answer
end
