# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "pumpjack_cost"

class BakuPumpjackImageCostTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/pumpjack_cost.yml", __dir__)

  def test_tokens_are_present_and_cost_is_nil
    result = nil
    Multivitamin::Cassettes.play(__dir__, "pumpjack_cost") do
      result = BakuPumpjackCost::PumpjackCost.conduct
    end

    assert_operator result.input_tokens, :>, 0
    assert_operator result.output_tokens, :>, 0
    assert_nil result.cost_total
    assert_nil result.cost_input
    assert_nil result.cost_output

    body = response_body
    assert_includes body, "input_tokens"
    assert_includes body, "output_tokens"
    refute_includes body, '"cost":'
    assert_includes request_body, "Balakhani"
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_body
    YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0).dig("request", "body", "string")
  end

  def response_body
    YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0).dig("response", "body", "string")
  end
end
