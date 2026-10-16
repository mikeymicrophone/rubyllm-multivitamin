# frozen_string_literal: true

require "minitest/autorun"
require_relative "township_board"

class BulawayoTownshipBoardTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/township_board.yml", __dir__)

  def test_the_threatening_slip_is_flagged
    result = nil
    Multivitamin::Cassettes.play(__dir__, "township_board") do
      result = BulawayoTownshipBoard::TownshipBoard.conduct
    end

    assert result.flagged
    refute_empty result.categories
    assert_includes result.categories, "violence"
    assert_operator result.violence_score, :>, 0
    assert_includes result.model, "omni-moderation"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
