# frozen_string_literal: true

require "minitest/autorun"
require_relative "potato_comments"

class CuscoPotatoLotCommentsTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/potato_comments.yml", __dir__)

  def test_the_batch_flags_only_the_threatening_lot
    result = nil
    Multivitamin::Cassettes.play(__dir__, "potato_comments") do
      result = CuscoPotatoLot::PotatoComments.conduct
    end

    assert result.outer_flagged
    assert_equal 3, result.result_count
    assert_equal 3, result.flags.length
    refute result.flags[0]
    refute result.flags[1]
    assert result.flags[2]
    assert_includes result.categories, "violence"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
