# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "yaml"
require_relative "slip_wind"

class SlipWindTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/slip_wind.yml", __dir__)

  def test_both_masts_come_back_as_json_from_one_turn
    result = nil
    Multivitamin::Cassettes.play(__dir__, "slip_wind") do
      result = PortTownsendSlipWind::MastRound.conduct
    end

    assert_equal 2, result.call_count
    assert_equal 2, result.tool_contents.size
    readings = result.tool_contents.map { |content| JSON.parse(content) }
    assert_equal [18, 22], readings.map { |reading| reading.fetch("knots") }.sort
    assert_equal [27, 31], readings.map { |reading| reading.fetch("gust") }.sort
    assert_includes result.answer, "27"
    assert_includes result.answer, "31"
    assert_equal %i[system user assistant tool tool assistant], result.roles

    request = YAML.load_file(CASSETTE).dig("http_interactions", 0, "request", "body", "string")
    assert_includes request, '"parallel_tool_calls":true'
    refute_includes request, '"knots"'
  end

  def test_a_hash_return_is_json_and_a_string_return_is_not
    reading = PortTownsendSlipWind::SlipAnemometer.new.execute(mast: "north")
    content, = PortTownsendSlipWind::SlipAnemometer.split_result(reading)

    assert_kind_of Hash, reading
    assert_kind_of String, content
    assert_equal reading, JSON.parse(content)
    assert_equal "north mast note", PortTownsendSlipWind::SlipAnemometer.split_result("north mast note").first
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
    refute_includes cassette, "Bearer sk-"
  end
end
