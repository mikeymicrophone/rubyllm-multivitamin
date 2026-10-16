# frozen_string_literal: true

require "minitest/autorun"
require_relative "sega_tokens"

class PortLouisSegaTokensTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/sega_tokens.yml", __dir__)

  def test_the_market_set_reports_usage
    result = nil
    Multivitamin::Cassettes.play(__dir__, "sega_tokens") do
      result = PortLouisSegaTokens::SegaTokens.conduct
    end

    assert_equal 1, result.index
    assert_includes result.model, "rerank"
    if result.input_tokens.nil?
      assert_nil result.cost
    else
      assert_operator result.input_tokens, :>, 0
      assert_operator result.cost, :>=, 0
    end
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
