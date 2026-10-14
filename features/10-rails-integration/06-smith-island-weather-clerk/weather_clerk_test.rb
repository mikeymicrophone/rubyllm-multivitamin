# frozen_string_literal: true

require "minitest/autorun"
require_relative "weather_clerk"

class PersistedSmithIslandWeatherClerkTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/weather_clerk.yml", __dir__)

  def test_the_weather_log_keeps_two_system_rows
    result = nil
    Multivitamin::Cassettes.play(__dir__, "weather_clerk") do
      result = SmithIslandWeatherClerk::WeatherClerk.conduct
    end

    assert_includes result.brief, "29.84"
    assert_equal 2, result.system_count
    assert_equal 2, result.reloaded_system_count
    assert_includes result.system_texts.fetch(0), "Smith Island"
    assert_includes result.system_texts.fetch(1), "18 knots"
    assert_equal %i[system system user assistant], result.roles
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
