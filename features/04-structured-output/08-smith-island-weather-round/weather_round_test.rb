# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "yaml"
require_relative "weather_round"

class SmithIslandWeatherRoundTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/weather_round.yml", __dir__)

  def test_numbers_stay_numbers_and_the_score_uses_level_indexes
    result = nil
    Multivitamin::Cassettes.play(__dir__, "weather_round") do
      result = SmithIslandWeatherRound::Clipboard.conduct
    end

    assert_in_delta 30.12, result.parsed["pressure_inhg"], 0.001
    assert_kind_of Float, result.parsed["pressure_inhg"]
    assert_equal 8, result.parsed["wind_knots"]
    assert_kind_of Integer, result.parsed["wind_knots"]
    assert_equal 48, result.parsed["temperature_f"]
    refute_kind_of String, result.parsed["temperature_f"]
    assert_equal "west", result.parsed["direction"]
    assert_operator result.score, :<, 0.5
    assert_equal [
      "Calm enough for the skiff to leave the float",
      "Choppy. Wait for a lull",
      "Too rough to leave"
    ], result.levels
    assert_operator result.probabilities[0], :>, result.probabilities[2]
    assert_operator result.confidence, :>, 0.9
    assert_operator result.cost, :>, 0

    decision = JSON.parse(request_bodies.fetch(1))
    assert_equal "https://api.openai.com/v1/decisions", request_uris.fetch(1)
    assert_equal "gpt-6-luna", decision["model"]
    question = decision["questions"].fetch(0)
    assert_equal "score", question["type"]
    assert_equal "sea_state", question["name"]
    assert_equal %w[0 1 2], question["levels"].map { |level| level["label"] }
    assert_equal "Calm enough for the skiff to leave the float", question["levels"].fetch(0)["description"]
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    interactions.map { |hit| hit.dig("request", "body", "string") }
  end

  def request_uris
    interactions.map { |hit| hit.dig("request", "uri") }
  end

  def interactions
    YAML.load_file(CASSETTE).fetch("http_interactions")
  end
end
