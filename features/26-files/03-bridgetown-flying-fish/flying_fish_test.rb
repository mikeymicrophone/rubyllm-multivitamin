# frozen_string_literal: true

require "minitest/autorun"
require_relative "flying_fish"

class BridgetownFlyingFishExpiryTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/flying_fish.yml", __dir__)

  def test_the_card_carries_an_expiry
    result = nil
    Multivitamin::Cassettes.play(__dir__, "flying_fish") do
      result = BridgetownFlyingFish::FlyingFish.conduct
    end

    assert_match(/\Afile-/, result.file_id)
    assert_instance_of Time, result.expires_at
    assert_operator result.expires_at, :>, Time.utc(2026, 10, 16)
    assert_equal "user_data", result.purpose
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
