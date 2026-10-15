# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "flagler_cost"

class FortFlaglerSpeechTokensCostTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/flagler_cost.yml", __dir__)

  def test_tokens_and_cost_are_nil_on_tts_one
    result = nil
    Multivitamin::Cassettes.play(__dir__, "flagler_cost") do
      result = FortFlaglerTokensCost::FlaglerCost.conduct
    end

    assert_equal "tts-1", result.model
    assert_nil result.input_tokens
    assert_nil result.output_tokens
    assert_nil result.cost_total
    assert_nil result.cost_input
    assert_nil result.cost_output

    request = request_body
    assert_includes request, "Fort Flagler"
    assert_includes request, '"model":"tts-1"'
    refute_includes response_body.to_s, "input_tokens"
    refute_includes response_body.to_s, '"cost":'
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
