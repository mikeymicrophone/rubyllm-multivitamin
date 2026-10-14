# frozen_string_literal: true

require "minitest/autorun"
require_relative "weather_logger"

class SmithIslandLoggerTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/weather_logger.yml", __dir__)

  def test_the_station_logger_receives_the_horn_round_request
    result = nil
    Multivitamin::Cassettes.play(__dir__, "weather_logger") do
      result = SmithIslandLogger::WeatherLogger.conduct
    end

    assert_includes result.round, "15"
    assert_includes result.round, "29.92"
    assert result.after_clear_uses_station_logger
    assert_match(/POST/i, result.log_text)
    assert_match(/chat\/completions/, result.log_text)
    refute_match(/RUBYLLM_DEBUG/, result.log_text)
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
