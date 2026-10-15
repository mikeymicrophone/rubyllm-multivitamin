# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "yaml"
require_relative "drone_pattern"

class DronePatternTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/drone_pattern.yml", __dir__)

  def test_the_enum_and_the_decisions_choice_name_the_same_pattern
    result = nil
    Multivitamin::Cassettes.play(__dir__, "drone_pattern") do
      result = YerevanDudukDrone::DronePattern.conduct
    end

    assert_equal "three-second drone", result.parsed["pattern"]
    assert_equal 92, result.parsed["reed_mm"]
    assert_kind_of Integer, result.parsed["reed_mm"]
    assert_equal :three_second_drone, result.choice
    assert_operator result.probabilities[:three_second_drone], :>, 0.9
    assert_operator result.probabilities[:three_second_drone], :>, result.probabilities[:silent]
    assert_operator result.confidence, :>, 0.9
    assert_equal %i[system user assistant], result.roles
    assert_equal :stop, result.finish
    assert_operator result.cost, :>, 0

    schema_request = JSON.parse(request_bodies.fetch(0))
    decision_request = JSON.parse(request_bodies.fetch(1))
    assert_equal "https://api.openai.com/v1/responses", request_uris.fetch(0)
    assert_equal "https://api.openai.com/v1/decisions", request_uris.fetch(1)
    assert_equal "gpt-4.1-mini", schema_request["model"]
    assert_equal ["three-second drone", "two-breath group", "silent"],
                 schema_request.dig("text", "format", "schema", "properties", "pattern", "enum")
    assert_nil schema_request["questions"]
    assert_equal "gpt-6-luna", decision_request["model"]
    assert_equal ["model", "input", "questions"], decision_request.keys
    assert_nil decision_request["text"]
    question = decision_request["questions"].fetch(0)
    assert_equal "choice", question["type"]
    assert_equal "pattern", question["name"]
    assert_equal "three_second_drone", question["choices"].fetch(0)["value"]
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    interactions.map { |hit| hit.dig("request", "body", "string") }
  end

  def request_uris
    interactions.map { |hit| hit.dig("request", "uri") }
  end

  def interactions
    YAML.load_file(CASSETTE).fetch("http_interactions")
  end
end
