# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "barometer_glass"

class BarometerGlassTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/barometer_glass.yml", __dir__)

  def test_a_raised_glass_is_not_sent_back_as_a_tool_message
    skip "cassette pending live recording" unless File.exist?(CASSETTE) || Multivitamin::Cassettes.live?

    result = nil
    Multivitamin::Cassettes.play(__dir__, "barometer_glass") do
      result = SmithIslandBarometer::GlassCheck.conduct
    end

    assert_instance_of SmithIslandBarometer::GlassUnseated, result.error
    assert_match(/off the board/, result.error.message)
    assert_match(/Smith Island/, result.error.message)
    assert_equal %i[system user assistant], result.roles
    assert result.tool_called
    refute_includes result.roles, :tool

    request = YAML.load_file(CASSETTE).dig("http_interactions", 0, "request", "body", "string")
    assert_includes request, "station_barometer"
    assert_equal 1, YAML.load_file(CASSETTE).fetch("http_interactions").size
  end

  def test_execute_raises_before_it_can_return_a_reading
    tool = SmithIslandBarometer::StationBarometer.new

    error = assert_raises(SmithIslandBarometer::GlassUnseated) do
      tool.execute(station: "Smith Island")
    end
    assert_includes error.message, "Smith Island"
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette pending live recording" unless File.exist?(CASSETTE)

    cassette = File.read(CASSETTE)

    refute_match(/sk-or-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
