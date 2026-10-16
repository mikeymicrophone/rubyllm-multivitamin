# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "ash_gate"

class QuetzaltenangoAshGateCapTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/ash_gate.yml", __dir__)

  def test_a_tight_output_budget_finishes_as_max_tokens
    result = nil
    Multivitamin::Cassettes.play(__dir__, "ash_gate") do
      result = QuetzaltenangoAshGate::AshGate.conduct
    end

    assert_equal true, result.max_tokens
    assert_equal :max_tokens, result.finish
    assert_equal QuetzaltenangoAshGate::AshGate::OUTPUT_BUDGET, result.output_cap
    assert_equal result.output_cap, result.output_tokens
    assert_operator result.input_tokens, :>, 0
    assert_equal 200, result.raw_status

    request = YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0).dig("request", "body", "string")
    assert_includes request, '"max_tokens":64'
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
