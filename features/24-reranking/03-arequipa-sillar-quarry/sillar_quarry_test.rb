# frozen_string_literal: true

require "minitest/autorun"
require_relative "sillar_quarry"

class ArequipaSillarQuarryIndexTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/sillar_quarry.yml", __dir__)

  def test_the_index_points_at_bay_c
    result = nil
    Multivitamin::Cassettes.play(__dir__, "sillar_quarry") do
      result = ArequipaSillarQuarry::SillarQuarry.conduct
    end

    assert_equal 2, result.index
    assert_equal "C", result.bay
    assert_equal "white sillar", result.stone
    assert_includes result.note, "cathedral lintel"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
