# frozen_string_literal: true

# Structured output · 03 · Yerevan duduk drone card
#
# Teaches:
# - A string enum constrains the pattern with_schema will accept.
# - RubyLLM::Judge is a different call. It posts to OpenAI Decisions
#   (POST /v1/decisions) on gpt-6-luna, and a choice question returns one
#   of the declared options plus a probability for each.
# - The schema structures a card. The judgment decides from the same card
#   without a JSON schema.

require "json"
require_relative "../../../support/runtime"

module YerevanDudukDrone
  class DroneCard < Schematist::Schema
    title "drone_card"
    description "The duduk drone pattern posted at the Komitas chamber"

    string :pattern,
           enum: ["three-second drone", "two-breath group", "silent"],
           description: "The pattern named on the card"
    integer :reed_mm, description: "Reed facing in millimetres, as an integer"
  end

  # Decisions choice. The descriptions are the instructions; the method
  # name is only how Ruby reads the answer back.
  class PatternCall < RubyLLM::Judge
    model Multivitamin::Models::OPENAI_JUDGMENT, provider: :openai

    choice :pattern, "Which duduk drone does the card post?" do
      three_second_drone "One drone of about three seconds, then a long silence"
      two_breath_group "Two short breaths grouped together"
      silent "The duduk is secured and not sounding"
    end
  end

  class DronePattern
    INSTRUCTIONS = <<~TEXT.strip
      You are the duduk clerk at the Komitas chamber in Yerevan.
      Fill drone_card from the card. Use the enum value that matches the card.
      Copy the reed facing as an integer.
    TEXT

    CARD = <<~TEXT.strip
      Yerevan duduk drone card for Wednesday 14 October 2026.
      Chamber: https://www.komitas.am/
      Pattern posted: one drone of three seconds, then silent 27 seconds.
      Do not use the two-breath group. The duduk is not silent.
      Reed facing 92 mm.
    TEXT

    Result = Struct.new(
      :parsed, :choice, :probabilities, :confidence, :roles, :finish, :input_tokens, :cost,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_schema(DroneCard)
      answer = chat.ask(CARD)

      judgment = PatternCall.judge(CARD)
      pattern = judgment.pattern

      Result.new(
        parsed: answer.parsed,
        choice: pattern.choice,
        probabilities: pattern.probabilities,
        confidence: pattern.confidence,
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
  result = Multivitamin::Cassettes.play(__dir__, "drone_pattern") do
    YerevanDudukDrone::DronePattern.conduct
  end

  puts JSON.generate(result.parsed)
  puts({ choice: result.choice, probabilities: result.probabilities, confidence: result.confidence }.inspect)
end
