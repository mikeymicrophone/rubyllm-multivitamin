# frozen_string_literal: true

# Structured output · 01 · Ubud subak water board
#
# Teaches:
# - with_schema takes a Schematist::Schema subclass. RubyLLM 2.1.1 has no
#   RubyLLM::Schema class. RubyLLM::Models::Schema validates the model
#   registry, and it is not the chat DSL.
# - response.content stays the JSON text. response.parsed is the Hash.
# - Parsed keys are strings. A number field comes back as a number.
# - A Schematist title becomes the schema name on the wire.

require "json"
require_relative "../../../support/runtime"

module UbudSubakBoard
  class PostedSubakBoard < Schematist::Schema
    title "posted_subak_board"
    description "Times and heights copied from the Tegalalang weir board"

    string :station, description: "Subak name, copied from the board"
    string :low_clock, description: "Clock time of low water, 24-hour HH:MM"
    number :low_height_cm, description: "Low water at the weir in centimetres, as a number"
    string :high_clock, description: "Clock time of high water, 24-hour HH:MM"
    number :high_height_cm, description: "High water at the weir in centimetres, as a number"
    string :wayan_clears, description: "Clock time Wayan clears the offtake"
    string :ketut_offtake, description: "Clock time Ketut can take the terrace"
  end

  class SubakHeights
    INSTRUCTIONS = <<~TEXT.strip
      You are the water clerk for Subak Pulagan at Tegalalang, Ubud.
      Fill posted_subak_board from the board in the question.
      Copy clock times and heights exactly. Do not invent a reading.
    TEXT

    BOARD = <<~TEXT.strip
      Tegalalang weir board for Wednesday 14 October 2026.
      Station page: https://whc.unesco.org/en/list/1194
      Low water 06:42, 0.4 cm at the weir.
      High water 12:18, 8.1 cm.
      Wayan clears the offtake at 10:46.
      Ketut can take the terrace at 08:57.
    TEXT

    Result = Struct.new(:content, :parsed, :roles, :finish, :input_tokens, :cost, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_schema(PostedSubakBoard)

      answer = chat.ask(BOARD)

      Result.new(
        content: answer.content,
        parsed: answer.parsed,
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
  result = Multivitamin::Cassettes.play(__dir__, "subak_heights") do
    UbudSubakBoard::SubakHeights.conduct
  end

  puts result.content
  puts JSON.generate(result.parsed)
end
