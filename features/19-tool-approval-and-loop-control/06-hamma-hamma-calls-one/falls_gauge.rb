# frozen_string_literal: true

# Tool approval and loop control · 06 · Hamma Hamma calls: :one
#
# Teaches:
# - calls: :one sends parallel_tool_calls false, so one assistant turn
#   carries a single falls reading even when the watch wants both.
# - The loop may still call the other reach on a later turn. The cap is
#   per response, not per conversation.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module HammaHammaCallsOne
  class FallsGauge < RubyLLM::Tool
    description "Reads one Hamma Hamma falls gauge. Call once per reach, upper or lower."

    def self.tool_name
      "falls_gauge"
    end

    parameter :reach, type: :string, description: "upper or lower falls", required: true

    CARDS = {
      "upper" => "Upper Hamma Hamma falls: 2.1 ft over the lip.",
      "lower" => "Lower Hamma Hamma falls: 5.4 ft in the plunge pool."
    }.freeze

    def execute(reach:)
      CARDS.fetch(reach.to_s.downcase) { "No gauge named #{reach} on the Hamma Hamma." }
    end
  end

  class FallsWatch
    INSTRUCTIONS = <<~TEXT.strip
      You are the falls watch on the Hamma Hamma.
      Call falls_gauge for the upper reach and for the lower reach.
      You may only put one function call in a single assistant message.
      After both cards are back, answer in one short sentence that names
      both figures the gauges return.
    TEXT

    FALLS_QUESTION = <<~TEXT.strip
      Thursday 15 October 2026, gauge round at the Hamma Hamma falls.
      Forest notes: https://www.fs.usda.gov/olympic
      Read the upper falls and the lower falls.
    TEXT

    Result = Struct.new(
      :first_call_count,
      :tool_contents,
      :answer,
      :roles,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_tools(FallsGauge)
      chat.with_tool_options(choice: :required, calls: :one)

      answer = chat.ask(FALLS_QUESTION)
      first_tool_turn = chat.messages.find(&:tool_call?)

      Result.new(
        first_call_count: first_tool_turn&.tool_calls&.size,
        tool_contents: chat.messages.select { |message| message.role == :tool }.map(&:content),
        answer: answer.content,
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
  Multivitamin::Cassettes.play(__dir__, "falls_gauge") do
    result = HammaHammaCallsOne::FallsWatch.conduct
  end

  puts result.answer
end
