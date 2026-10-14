# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "yaml"
require_relative "berth_slip"

class BerthSlipTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/berth_slip.yml", __dir__)

  def test_a_manual_schema_without_a_name_is_called_response
    result = nil
    Multivitamin::Cassettes.play(__dir__, "berth_slip") do
      result = FridayHarborBerthSlip::SlipAssignment.conduct
    end

    assert_equal "7", result.parsed["slip"]
    assert_kind_of String, result.parsed["slip"]
    assert_equal "F/V Kulshan", result.parsed["boat"]
    assert_in_delta 11.2, result.parsed["depth_ft"], 0.001
    assert_equal "port", result.parsed["alongside"]
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
