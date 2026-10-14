# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "compressor_card"

class CompressorCardTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/compressor_card.yml", __dir__)

  def test_the_gauge_is_compared_with_the_posted_minimum
    skip "cassette pending live recording" unless File.exist?(CASSETTE)

    result = nil
    Multivitamin::Cassettes.play(__dir__, "compressor_card") do
      result = CapeDisappointmentCompressor::GaugeCheck.conduct
    end

    assert_includes result.tool_content, "92"
    assert_includes result.tool_content, "clears"
    assert_includes result.tool_content, "85"
    assert_includes result.answer, "85"
    assert_match(/clear/i, result.answer)
    assert_equal %i[system user assistant tool assistant], result.roles

    request = YAML.load_file(CASSETTE).dig("http_interactions", 0, "request", "body", "string")
    assert_includes request, '"psi":{"type":"number","description":"Compressor pressure in psi from the gauge"}'
    assert_includes request, '"station":{"type":"string","description":"Horn station the gauge belongs to"}'
    assert_includes request, '"required":["psi","station"]'
    refute_includes request, "85"
  end

  def test_parameter_declares_a_number_and_a_required_station
    schema = CapeDisappointmentCompressor::CompressorCard.new.parameters_schema

    assert_equal "number", schema.dig("properties", "psi", "type")
    assert_equal "Compressor pressure in psi from the gauge", schema.dig("properties", "psi", "description")
    assert_equal "string", schema.dig("properties", "station", "type")
    assert_equal %w[psi station], schema.fetch("required")

    reading = CapeDisappointmentCompressor::CompressorCard.new.execute(psi: 92, station: "Cape Disappointment")
    assert_includes reading, "clears the 85 psi posted minimum"
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette pending live recording" unless File.exist?(CASSETTE)

    cassette = File.read(CASSETTE)

    refute_match(/sk-or-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
