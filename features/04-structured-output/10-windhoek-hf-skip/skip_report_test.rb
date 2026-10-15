# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "yaml"
require_relative "skip_report"

class SkipReportTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/skip_report.yml", __dir__)

  def test_the_stream_joins_into_json_and_parsed_uses_string_keys
    result = nil
    Multivitamin::Cassettes.play(__dir__, "skip_report") do
      result = WindhoekHfSkip::SkipBoard.conduct
    end

    assert_kind_of String, result.content
    assert_equal result.content, result.pieces.map(&:to_s).join
    assert_operator result.pieces.count { |piece| piece.is_a?(String) && !piece.empty? }, :>, 1
    assert_equal result.parsed, JSON.parse(result.content)
    assert result.parsed.keys.all? { |key| key.is_a?(String) }
    assert_equal "southwest", result.parsed["direction"]
    assert_equal 18, result.parsed["mhz"]
    assert_equal 24, result.parsed["peaks"]
    assert_kind_of Integer, result.parsed["mhz"]
    assert_equal %i[system user assistant], result.roles
    assert_equal :stop, result.finish
    assert_operator result.cost, :>, 0

    request = JSON.parse(request_bodies.fetch(0))
    assert_equal true, request["stream"]
    assert_equal "skip_report", request.dig("text", "format", "name")
    response = YAML.load_file(CASSETTE).dig("http_interactions", 0, "response", "body", "string")
    assert_includes response, "response.output_text.delta"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map { |hit| hit.dig("request", "body", "string") }
  end
end
