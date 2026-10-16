# frozen_string_literal: true

require "minitest/autorun"
require_relative "cork"

class EvoraCorkThinkingPersistTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/cork.yml", __dir__)

  def test_the_cork_log_keeps_thinking_text_after_reload
    result = nil
    Multivitamin::Cassettes.play(__dir__, "cork") do
      result = EvoraCorkPlank::CorkClerk.conduct
    end

    assert_includes result.brief, "Inês"
    assert_includes result.brief, "12:30"
    refute_nil result.thinking_signature
    refute_empty result.thinking_signature
    assert_equal result.thinking_signature, result.reloaded_signature
    assert_equal result.thinking_text.to_s, result.reloaded_text.to_s
    assert_equal 1, result.assistant_count
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
