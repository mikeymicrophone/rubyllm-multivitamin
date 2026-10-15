# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "yaml"
require_relative "fog_signal_cost"

class FoulweatherBluffFogSignalZeroCostTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/fog_signal_cost.yml", __dir__)

  def test_a_reported_zero_is_zero_not_nil
    result = nil
    Multivitamin::Cassettes.play(__dir__, "fog_signal_cost") do
      result = FoulweatherBluffFogSignal::FogSignalCost.conduct
    end

    assert_includes result.brief, "4"
    assert_match(/16/, result.brief)
    refute_nil result.cost_total
    assert_equal 0, result.cost_total
    assert_equal 0, result.reported_cost
    assert_equal false, result.cost_is_nil
    assert_operator result.input_tokens, :>, 0
    assert_operator result.output_tokens, :>, 0

    usage = JSON.parse(response_body).fetch("usage")
    assert_equal 0, usage.fetch("cost")
    assert_equal usage.fetch("cost"), result.cost_total
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end

  def response_body
    YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0).dig("response", "body", "string")
  end
end
