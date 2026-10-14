# frozen_string_literal: true

# Structured output · 08 · Smith Island weather round
#
# Teaches:
# - number and integer fields parse as Numeric, not as strings.
# - A Judge score is the Decisions form of an ordered scale. RubyLLM posts
#   it as a score question. The score can fall between level indexes.

require "json"
require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module SmithIslandWeatherRound
  class WeatherRound < Schematist::Schema
    title "weather_round"
    description "Smith Island weather clipboard"

    number :pressure_inhg, description: "Barometer in inches of mercury, as a number, not a string"
    integer :wind_knots, description: "Wind speed in knots, as an integer"
    number :temperature_f, description: "Air temperature in Fahrenheit, as a number"
    string :direction, description: "Wind direction word from the clipboard"
  end

  class SeaStateCall < RubyLLM::Judge
    model Multivitamin::Models::OPENAI_JUDGMENT, provider: :openai

    score :sea_state, "How rough is the strait for the station skiff right now?",
          [
            "Calm enough for the skiff to leave the float",
            "Choppy. Wait for a lull",
            "Too rough to leave"
          ]
  end

  class Clipboard
    INSTRUCTIONS = <<~TEXT.strip
      You are the weather watch at Smith Island.
      Fill weather_round from the clipboard.
      pressure_inhg, wind_knots, and temperature_f must be numbers, not strings.
    TEXT

    CLIPBOARD = <<~TEXT.strip
      Smith Island weather round, Wednesday 14 October 2026, 07:00.
      Compare later with https://www.ndbc.noaa.gov/.
      Barometer 30.12 inches.
      Wind west at 8 knots. No gusts.
      Air 48 F.
      Sea: smooth. The skiff can leave the float.
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
      chat.with_schema(WeatherRound)
      answer = chat.ask(CLIPBOARD)

      judgment = SeaStateCall.judge(CLIPBOARD)
      sea = judgment.sea_state

      Result.new(
        parsed: answer.parsed,
        score: sea.score,
        levels: sea.levels,
        probabilities: sea.probabilities,
        confidence: sea.confidence,
        roles: chat.messages.map(&:role),
        finish: answer.finish_reason,
        input_tokens: answer.tokens.input,
        cost: answer.cost.total
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
  Multivitamin::Cassettes.play(__dir__, "weather_round") do
    result = SmithIslandWeatherRound::Clipboard.conduct
  end

  puts JSON.generate(result.parsed)
  puts({ score: result.score, probabilities: result.probabilities, confidence: result.confidence }.inspect)
end
