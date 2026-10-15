# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "yaml"
require_relative "gate_state"

class GateStateTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/gate_state.yml", __dir__)

  def test_clearing_the_schema_returns_prose_and_a_second_schema_follows
    result = nil
    Multivitamin::Cassettes.play(__dir__, "gate_state") do
      result = ChengduPandaGate::GateLog.conduct
    end

    assert_equal "shut", result.gate["gate"]
    assert_in_delta 18.4, result.gate["moat_cm"], 0.001
    assert_kind_of String, result.prose
    refute result.prose.lstrip.start_with?("{")
    assert_includes result.prose, "moat"
    assert_raises(JSON::ParserError) { JSON.parse(result.prose) }
    assert_equal "afternoon", result.note["watch"]
    assert_includes result.note["note"], "shut"
    assert_equal %i[system user assistant user assistant user assistant], result.roles
    assert_equal :stop, result.finish

    requests = request_bodies.map { |body| JSON.parse(body) }
    assert_equal "gate_state", requests[0].dig("text", "format", "name")
    assert_nil requests[1]["text"]
    refute_includes request_bodies[1], "json_schema"
    assert_includes JSON.generate(requests[1]["input"]), "18.4"
    assert_equal "crew_note", requests[2].dig("text", "format", "name")
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
