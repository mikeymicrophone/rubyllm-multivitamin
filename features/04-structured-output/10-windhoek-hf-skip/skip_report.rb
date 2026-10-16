# frozen_string_literal: true

# Structured output · 10 · Windhoek HF skip board
#
# Teaches:
# - ask with a block streams a schema the same way it streams prose.
# - Chunk content is a piece of the JSON text. Joining the pieces equals
#   message.content. message.parsed is the Hash, and its keys are strings.

require "json"
require_relative "../../../support/runtime"

module WindhoekHfSkip
  class SkipReport < Schematist::Schema
    title "skip_report"
    description "HF skip at the Windhoek radio club"

    string :direction, description: "Skip direction word from the board"
    integer :mhz, description: "Sustained frequency in megahertz"
    integer :peaks, description: "Peak frequency in megahertz"
  end

  class SkipBoard
    INSTRUCTIONS = <<~TEXT.strip
      You are the skip watch at the Windhoek radio club.
      Fill skip_report from the board. Copy the numbers as integers.
    TEXT

    BOARD = <<~TEXT.strip
      Windhoek HF skip board, Wednesday 14 October 2026, 07:40.
      Club page: https://www.crasa.org/
      Skip southwest at 18 MHz, peaks 24.
    TEXT

    Result = Struct.new(:content, :parsed, :pieces, :roles, :finish, :input_tokens, :cost, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_schema(SkipReport)

      pieces = []
      answer = chat.ask(BOARD) do |chunk|
        pieces << chunk.content
      end

      Result.new(
        content: answer.content,
        parsed: answer.parsed,
        pieces: pieces,
        roles: chat.messages.map(&:role),
        finish: answer.finish_reason,
        input_tokens: answer.tokens.input,
        cost: answer.cost.total
      )
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
    end

    def self.configure = Multivitamin::Runtime.configure(provider: :openai, timeout: 180)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "skip_report") do
    WindhoekHfSkip::SkipBoard.conduct
  end

  puts result.content
  puts JSON.generate(result.parsed)
  puts "pieces=#{result.pieces.size}"
end
