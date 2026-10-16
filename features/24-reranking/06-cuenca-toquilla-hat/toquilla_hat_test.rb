# frozen_string_literal: true

require "minitest/autorun"
require_relative "toquilla_hat"

class CuencaToquillaHatTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/toquilla_hat.yml", __dir__)

  def test_the_spanish_query_picks_the_fino_block
    result = nil
    Multivitamin::Cassettes.play(__dir__, "toquilla_hat") do
      result = CuencaToquillaHat::ToquillaHat.conduct
    end

    assert_equal 1, result.index
    assert_includes result.document, "fino"
    assert_operator result.score, :>, 0
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
