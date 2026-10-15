# frozen_string_literal: true

# Tools · 03 · Olkaria wellhead card
#
# Teaches:
# - parameter declares a type, a description, and required.
# - A number stays a number in the schema. The posted minimum is not
#   in the question. The tool is what compares the gauge.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module OlkariaWellhead
  # The gauge reading comes from the plant. The posted minimum lives here.
  class WellheadCard < RubyLLM::Tool
    description "Compares a geothermal wellhead gauge with the posted minimum at Olkaria"

    def self.tool_name
      "wellhead_card"
    end

    parameter :pressure, type: :number, description: "Wellhead pressure in bar from the gauge", required: true
    parameter :station, type: :string, description: "Well pad the gauge belongs to", required: true

    POSTED_MINIMUM_BAR = 85

    def execute(pressure:, station:)
      reading = pressure.to_f
      verdict = reading >= POSTED_MINIMUM_BAR ? "clears" : "is below"
      "#{station} wellhead at #{reading} bar #{verdict} the #{POSTED_MINIMUM_BAR} bar posted minimum."
    end
  end

  class GaugeCheck
    INSTRUCTIONS = <<~TEXT.strip
      You are the wellhead watch at Olkaria, Kenya.
      Call wellhead_card with the station and the pressure from the question.
      Answer in one sentence. Include the posted minimum the tool names and whether the gauge clears it.
    TEXT

    GAUGE_QUESTION = <<~TEXT.strip
      Wellhead watch at Olkaria IV, Thursday 15 October 2026.
      Plant notes: https://www.kengen.co.ke/
      The gauge on well OW-914 reads 92 bar.
      Does this pad's wellhead clear the posted minimum?
    TEXT

    Result = Struct.new(:answer, :roles, :tool_content, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_tools(WellheadCard)
      chat.with_tool_options(choice: WellheadCard)

      answer = chat.ask(GAUGE_QUESTION)
      tool_message = chat.messages.find { |message| message.role == :tool }

      Result.new(
        answer: answer.content,
        roles: chat.messages.map(&:role),
        tool_content: tool_message&.content
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
  Multivitamin::Cassettes.play(__dir__, "wellhead_card") do
    result = OlkariaWellhead::GaugeCheck.conduct
  end

  puts result.answer
end
