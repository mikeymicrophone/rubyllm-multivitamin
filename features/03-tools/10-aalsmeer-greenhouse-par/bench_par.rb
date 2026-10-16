# frozen_string_literal: true

# Tools · 10 · Aalsmeer greenhouse PAR
#
# Teaches:
# - with_tool_options(calls: :many) sends parallel_tool_calls true so one
#   assistant turn can carry two calls.
# - A Hash return is JSON on the tool message. A String return, as on the
#   auction chalkboard, is not.

require_relative "../../../support/runtime"

module AalsmeerGreenhousePar
  class BenchPar < RubyLLM::Tool
    description "Reads one PAR sensor bench at the Aalsmeer greenhouse. Call once per bench."

    def self.tool_name
      "bench_par"
    end

    parameter :bench, type: :string, description: "east or west bench", required: true

    READINGS = {
      "east" => { "bench" => "east", "micromoles" => 18, "peak" => 27 },
      "west" => { "bench" => "west", "micromoles" => 22, "peak" => 31 }
    }.freeze

    def execute(bench:)
      READINGS.fetch(bench.to_s.downcase) { { "error" => "No PAR sensor named #{bench}." } }
    end
  end

  class BenchRound
    INSTRUCTIONS = <<~TEXT.strip
      You are the greenhouse watch at Aalsmeer.
      Your first message must contain exactly two function calls to bench_par,
      one with bench east and one with bench west.
      Do not wait for a tool result before the second call.
      Then answer in one sentence that includes both peaks.
    TEXT

    PAR_QUESTION = <<~TEXT.strip
      Thursday 15 October 2026, PAR round at the Aalsmeer greenhouse.
      Auction floor: https://www.royalfloraholland.com/
      Read the east bench and the west bench.
    TEXT

    Result = Struct.new(:answer, :roles, :tool_contents, :call_count, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_tools(BenchPar)
      chat.with_tool_options(choice: :auto, calls: :many)

      answer = chat.ask(PAR_QUESTION)
      tool_turn = chat.messages.find(&:tool_call?)

      Result.new(
        answer: answer.content,
        roles: chat.messages.map(&:role),
        tool_contents: chat.messages.select { |message| message.role == :tool }.map(&:content),
        call_count: tool_turn&.tool_calls&.size
      )
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
    end

    def self.configure = Multivitamin::Runtime.configure(provider: :openai, timeout: 180)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "bench_par") do
    AalsmeerGreenhousePar::BenchRound.conduct
  end

  puts result.answer
end
