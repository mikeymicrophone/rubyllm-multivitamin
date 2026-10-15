# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "yaml"
require_relative "spice_stall"

class SpiceStallTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/spice_stall.yml", __dir__)

  def test_a_manual_schema_without_a_name_is_called_response
    result = nil
    Multivitamin::Cassettes.play(__dir__, "spice_stall") do
      result = StoneTownSpiceStall::StallAssignment.conduct
    end

    assert_equal "7", result.parsed["stall"]
    assert_kind_of String, result.parsed["stall"]
    assert_equal "Amina Clove", result.parsed["seller"]
    assert_in_delta 11.2, result.parsed["frontage_m"], 0.001
    assert_equal "left", result.parsed["aisle"]
    assert_equal %i[system user assistant], result.roles
    assert_operator result.cost, :>, 0

    format = JSON.parse(request_bodies.fetch(0)).dig("text", "format")
    assert_equal "response", format["name"]
    assert_equal false, format.dig("schema", "additionalProperties")
    assert_equal true, format["strict"]
    refute format.key?("title")
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
