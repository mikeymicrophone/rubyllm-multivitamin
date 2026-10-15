# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "wellhead_card"

class WellheadCardTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/wellhead_card.yml", __dir__)

  def test_the_gauge_is_compared_with_the_posted_minimum
    result = nil
    Multivitamin::Cassettes.play(__dir__, "wellhead_card") do
      result = OlkariaWellhead::GaugeCheck.conduct
    end

    assert_includes result.tool_content, "92"
    assert_includes result.tool_content, "clears"
    assert_includes result.tool_content, "85"
    assert_includes result.answer, "85"
    assert_match(/clear/i, result.answer)
    assert_equal %i[system user assistant tool assistant], result.roles

    request = YAML.load_file(CASSETTE).dig("http_interactions", 0, "request", "body", "string")
    assert_includes request, '"pressure":{"type":"number","description":"Wellhead pressure in bar from the gauge"}'
    assert_includes request, '"station":{"type":"string","description":"Well pad the gauge belongs to"}'
    assert_includes request, '"required":["pressure","station"]'
    refute_includes request, "85"
  end

  def test_parameter_declares_a_number_and_a_required_station
    schema = OlkariaWellhead::WellheadCard.new.parameters_schema

    assert_equal "number", schema.dig("properties", "pressure", "type")
    assert_equal "Wellhead pressure in bar from the gauge", schema.dig("properties", "pressure", "description")
    assert_equal "string", schema.dig("properties", "station", "type")
    assert_equal %w[pressure station], schema.fetch("required")

    reading = OlkariaWellhead::WellheadCard.new.execute(pressure: 92, station: "Olkaria IV")
    assert_includes reading, "clears the 85 bar posted minimum"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
    refute_includes cassette, "Bearer sk-"
  end
end
