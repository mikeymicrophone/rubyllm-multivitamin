# frozen_string_literal: true

require "minitest/autorun"
require_relative "maize_scores"

class LilongweMaizeCribScoresTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/maize_scores.yml", __dir__)

  def test_the_clean_notice_still_has_score_keys
    result = nil
    Multivitamin::Cassettes.play(__dir__, "maize_scores") do
      result = LilongweMaizeCrib::MaizeScores.conduct
    end

    refute result.flagged
    assert_empty result.categories
    refute_empty result.score_keys
    assert_includes result.score_keys, "violence"
    assert_includes result.raw_keys, "category_scores"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
