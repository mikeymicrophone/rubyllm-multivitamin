# frozen_string_literal: true

require "minitest/autorun"
require_relative "parchment"

class GondarParchmentThinkingTokensTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/parchment.yml", __dir__)

  def test_thinking_tokens_sit_inside_output
    result = nil
    Multivitamin::Cassettes.play(__dir__, "parchment") do
      result = GondarParchmentFolio::ParchmentFolio.conduct
    end

    assert_includes result.brief, "Yonas"
    assert_includes result.brief, "14:00"
    assert_instance_of Integer, result.thinking_tokens
    assert_instance_of Integer, result.output_tokens
    assert_operator result.thinking_tokens, :>=, 0
    assert_operator result.output_tokens, :>=, result.thinking_tokens
    assert_nil result.thinking_cost
    refute_nil result.total_cost
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
