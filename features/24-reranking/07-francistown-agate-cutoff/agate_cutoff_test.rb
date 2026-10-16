# frozen_string_literal: true

require "minitest/autorun"
require_relative "agate_cutoff"

class FrancistownAgateCutoffTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/agate_cutoff.yml", __dir__)

  def test_the_desk_keeps_the_banded_lot_and_drops_the_glass
    result = nil
    Multivitamin::Cassettes.play(__dir__, "agate_cutoff") do
      result = FrancistownAgateCutoff::AgateCutoff.conduct
    end

    assert_equal 1, result.kept.fetch(0).fetch(:index)
    assert_operator result.top_score, :>, 0
    assert_operator result.kept.length, :>=, 1
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
