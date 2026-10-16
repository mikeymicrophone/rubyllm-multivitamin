# frozen_string_literal: true

require "minitest/autorun"
require_relative "bamboo"

class ShillongBambooStreamThinkingTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/bamboo.yml", __dir__)

  def test_streamed_thinking_deltas_join_the_message_text
    result = nil
    Multivitamin::Cassettes.play(__dir__, "bamboo") do
      result = ShillongBambooSplit::BambooSplit.conduct
    end

    assert_includes result.brief, "Bina"
    assert_includes result.brief, "11:20"
    refute_empty result.spoken_pieces
    assert_equal result.spoken_pieces.join, result.brief
    if result.thinking_text
      assert_equal result.thinking_pieces.join, result.thinking_text
    end
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
