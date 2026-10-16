# frozen_string_literal: true

# Structured output · 08 · La Paz radiosonde clipboard
#
# Teaches:
# - number and integer fields parse as Numeric, not as strings.
# - A Judge score is the Decisions form of an ordered scale. RubyLLM posts
#   it as a score question. The score can fall between level indexes.

require "json"
require_relative "../../../support/runtime"

module LaPazRadiosonde
  class BalloonRound < Schematist::Schema
    title "balloon_round"
    description "El Alto radiosonde clipboard"

    number :pressure_inhg, description: "Altimeter in inches of mercury, as a number, not a string"
    integer :wind_knots, description: "Wind speed in knots, as an integer"
    number :temperature_f, description: "Air temperature in Fahrenheit, as a number"
    string :direction, description: "Wind direction word from the clipboard"
  end

  class LaunchCall < RubyLLM::Judge
    model Multivitamin::Models::OPENAI_JUDGMENT, provider: :openai

    score :launch_state, "How rough is the Altiplano for the balloon launch right now?",
          [
            "Calm enough for the balloon to leave the shed",
            "Choppy. Wait for a lull",
            "Too rough to leave"
          ]
  end

  class Clipboard
    INSTRUCTIONS = <<~TEXT.strip
      You are the radiosonde watch at El Alto, La Paz.
      Fill balloon_round from the clipboard.
      pressure_inhg, wind_knots, and temperature_f must be numbers, not strings.
    TEXT

    CLIPBOARD = <<~TEXT.strip
      El Alto radiosonde round, Wednesday 14 October 2026, 07:00.
      Compare later with https://www.senamhi.gob.bo/
      Altimeter 30.12 inches.
      Wind west at 8 knots. No gusts.
      Air 48 F.
      Sky: smooth. The balloon can leave the shed.
    TEXT

    Result = Struct.new(
      :parsed, :score, :levels, :probabilities, :confidence, :roles, :finish, :input_tokens, :cost,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_schema(BalloonRound)
      answer = chat.ask(CLIPBOARD)

      judgment = LaunchCall.judge(CLIPBOARD)
      launch = judgment.launch_state

      Result.new(
        parsed: answer.parsed,
        score: launch.score,
        levels: launch.levels,
        probabilities: launch.probabilities,
        confidence: launch.confidence,
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
  result = Multivitamin::Cassettes.play(__dir__, "balloon_round") do
    LaPazRadiosonde::Clipboard.conduct
  end

  puts JSON.generate(result.parsed)
  puts({ score: result.score, probabilities: result.probabilities, confidence: result.confidence }.inspect)
end
