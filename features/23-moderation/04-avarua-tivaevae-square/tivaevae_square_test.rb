# frozen_string_literal: true

require "minitest/autorun"
require_relative "tivaevae_square"

class AvaruaTivaevaeSquareTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/tivaevae_square.yml", __dir__)

  def test_the_studio_square_is_not_flagged
    result = nil
    Multivitamin::Cassettes.play(__dir__, "tivaevae_square") do
      result = AvaruaTivaevaeSquare::TivaevaeSquare.conduct
    end

    refute result.flagged
    assert_empty result.categories
    assert_includes result.model, "omni-moderation"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
