# frozen_string_literal: true

require "minitest/autorun"
require "minitest/mock"
require_relative "mint_blank"

class CanberraMintBlankExpiryTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/mint_blank.yml", __dir__)

  def test_the_blank_is_not_expired_yet
    result = nil
    # The recorded upload expires at a fixed moment (2026-10-16 17:37 UTC).
    # Pin the clock to half an hour before that so the test keeps passing.
    recorded_open = Time.at(1_792_153_023 - 1800)
    Time.stub(:now, recorded_open) do
      Multivitamin::Cassettes.play(__dir__, "mint_blank") do
        result = CanberraMintBlank::MintBlank.conduct
      end
    end

    assert_match(/\Afile-/, result.file_id)
    refute result.expired
    assert_instance_of Time, result.expires_at
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
