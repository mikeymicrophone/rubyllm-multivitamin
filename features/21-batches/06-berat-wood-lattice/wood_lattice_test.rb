# frozen_string_literal: true

require "minitest/autorun"
require_relative "wood_lattice"

class BeratWoodLatticeTest < Minitest::Test
  def test_mixing_chats_and_embeds_raises_before_http
    result = BeratWoodLattice::LatticeMix.conduct

    assert_equal "ArgumentError", result.error_class
    assert_match(/chats or embedding/i, result.message)
  end
end
