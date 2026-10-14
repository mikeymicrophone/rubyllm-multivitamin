# frozen_string_literal: true

require "minitest/autorun"
require_relative "haiku_alias"

class LimeKilnHaikuAliasTest < Minitest::Test
  def test_the_same_alias_resolves_to_different_ids_on_two_channels
    result = nil
    Multivitamin::Cassettes.play(__dir__, "haiku_alias") do
      result = LimeKilnWhaleWatch::HaikuAlias.conduct
    end

    assert_equal "anthropic", result.bare_provider
    assert_equal "claude-haiku-4-5", result.bare_id

    assert_equal "anthropic", result.anthropic_provider
    assert_equal "claude-haiku-4-5-20251001", result.anthropic_id
    assert_equal "claude-haiku", result.anthropic_family
    assert_equal 200_000, result.anthropic_window

    assert_equal "bedrock", result.bedrock_provider
    assert_equal "anthropic.claude-haiku-4-5-20251001-v1:0", result.bedrock_id
    assert_equal "claude-haiku", result.bedrock_family
    assert_equal 200_000, result.bedrock_window

    refute_equal result.anthropic_id, result.bedrock_id
    refute_equal result.bare_id, result.anthropic_id
  end
end
