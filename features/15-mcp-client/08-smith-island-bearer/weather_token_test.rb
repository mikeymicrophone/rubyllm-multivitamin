# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "weather_token"

class SmithIslandMcpBearerAuthTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/weather_token.yml", __dir__)

  def test_bearer_and_oauth_both_reach_the_barometer
    result = nil
    Multivitamin::Cassettes.play(__dir__, "weather_token") do
      result = SmithIslandMcpBearer::WeatherToken.conduct
    end

    assert result.oauth_authorized
    assert_includes result.oauth_tool_names, "barometer_glass"
    assert_includes result.tool_content, "29.92"
    assert_includes result.answer, "Alden"
    assert_includes result.answer, "29.92"
    assert_includes result.roles, :tool
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
    refute_includes cassette, "AdmiraltyBarometer-14Oct2026"
    refute_includes cassette, "SmithIslandGlass-secret"
    refute_includes cassette, "SmithIslandOauth-round"
    assert_includes cassette, "<MCP_BEARER_TOKEN>"
    assert_includes cassette, "<MCP_OAUTH_ACCESS_TOKEN>"
    assert_includes cassette, "<MCP_CLIENT_SECRET>"
  end
end
