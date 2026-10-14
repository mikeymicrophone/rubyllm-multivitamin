# frozen_string_literal: true

# Tools · 09 · Bremerton dry dock sill
#
# Teaches:
# - The station the tool needs can sit later in the question. The first
#   sentence names the barge, not the dock.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module BremertonDryDockSill
  class SillCard < RubyLLM::Tool
    description "Reads the sill depth card for a Puget Sound dry dock"

    def self.tool_name
      "sill_card"
    end

    parameter :station, type: :string, description: "Dry dock station, such as Bremerton", required: true

    BREMERTON_CARD = "The sill at Bremerton dry dock is 38 ft at 10:30 on 14 October 2026."

    def execute(station:)
      return BREMERTON_CARD if station.to_s.match?(/bremerton/i)

      "No sill card for #{station}."
    end
  end

  class SillReading
    INSTRUCTIONS = <<~TEXT.strip
      You are the gate clerk at the Bremerton dry dock.
      Call sill_card with the dry dock station named in the question.
      Answer in one sentence and include the depth the tool returns.
    TEXT

    SILL_QUESTION = <<~TEXT.strip
      The repair barge Kulshan is waiting on the tide.
      Gate office: https://www.portofbremerton.org/
      She needs the sill depth at Bremerton before the 11:00 move.
      Read the sill card for that station.
    TEXT

    Result = Struct.new(:answer, :roles, :tool_content, :station, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_tools(SillCard)
      chat.with_tool_options(choice: SillCard)

      answer = chat.ask(SILL_QUESTION)
      tool_call = chat.messages.find(&:tool_call?)&.tool_calls&.values&.first
      tool_message = chat.messages.find { |message| message.role == :tool }

      Result.new(
        answer: answer.content,
        roles: chat.messages.map(&:role),
        tool_content: tool_message&.content,
        station: tool_call&.arguments&.fetch("station")
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
  Multivitamin::Cassettes.play(__dir__, "sill_depth") do
    result = BremertonDryDockSill::SillReading.conduct
  end

  puts result.answer
end
