# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "yaml"
require_relative "tide_heights"

class TideHeightsTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/tide_heights.yml", __dir__)

  def test_the_board_parses_as_a_hash_and_content_stays_json
    result = play

    assert_kind_of String, result.content
    assert_kind_of Hash, result.parsed
    assert_equal result.parsed, JSON.parse(result.content)
    assert result.parsed.keys.all? { |key| key.is_a?(String) }
    assert_equal "Point Wilson", result.parsed["station"]
    assert_equal "06:42", result.parsed["low_clock"]
    assert_in_delta 0.4, result.parsed["low_height_ft"], 0.001
    assert_kind_of Float, result.parsed["low_height_ft"]
    assert_equal "12:18", result.parsed["high_clock"]
    assert_in_delta 8.1, result.parsed["high_height_ft"], 0.001
    assert_equal "10:46", result.parsed["alden_clears"]
    assert_equal "08:57", result.parsed["retort_float"]
    assert_equal %i[system user assistant], result.roles
    assert_equal :stop, result.finish
    assert_operator result.input_tokens, :>, 0
    assert_operator result.cost, :>, 0

    request = JSON.parse(request_bodies.fetch(0))
    format = request.dig("text", "format")
    assert_equal "gpt-4.1-mini", request["model"]
    assert_equal false, request["stream"]
    assert_equal "json_schema", format["type"]
    assert_equal "posted_tide_board", format["name"]
    assert_equal true, format["strict"]
    refute request.dig("text", "format", "schema").key?("$schema")
    refute_includes request_bodies.fetch(0), "json-schema.org"
  end

  def test_the_chat_dsl_is_schematist_not_rubyllm_schema
    assert_raises(NameError) { RubyLLM::Schema }
    assert_operator PointWilsonTideHeights::PostedTideBoard, :<, Schematist::Schema
    assert_operator RubyLLM::Models::Schema, :<, Schematist::Schema
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
    refute_includes cassette, "Bearer sk-"
  end

  def play
    result = nil
    Multivitamin::Cassettes.play(__dir__, "tide_heights") { result = PointWilsonTideHeights::TideHeights.conduct }
    result
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map { |hit| hit.dig("request", "body", "string") }
  end
end
