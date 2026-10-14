# frozen_string_literal: true

require "minitest/autorun"
require_relative "weather_round"

class WeatherRoundTest < Minitest::Test
  def test_stopped_is_the_check_for_a_finished_round
    result = nil
    Multivitamin::Cassettes.play(__dir__, "weather_round") do
      result = PatosIslandWeather::WeatherRound.conduct
    end

    assert_equal true, result.stopped
    assert_equal :stop, result.finish_reason
    assert_match(/\bSE\b|southeast/i, result.round)
    assert_includes result.round, "15"
    assert_includes result.round, "4"
    assert_includes result.round, "29.92"
    assert_includes result.round, "2"
    refute_match(/tomorrow/i, result.round)
    assert_equal %i[system user assistant], result.roles
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/weather_round.yml", __dir__))

    refute_match(/sk-or-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
