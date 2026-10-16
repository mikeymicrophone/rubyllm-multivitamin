# frozen_string_literal: true

require "minitest/autorun"
require_relative "groundnut_hail"

class TamaleGroundnutPasteHailTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/groundnut_hail.yml", __dir__)

  def test_the_clean_mill_hail_is_not_flagged
    result = nil
    Multivitamin::Cassettes.play(__dir__, "groundnut_hail") do
      result = TamaleGroundnutPaste::GroundnutHail.conduct
    end

    refute result.flagged
    assert_empty result.categories
    assert_equal 1, result.result_count
    assert_includes result.model, "omni-moderation"
    refute_empty result.score_keys
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
