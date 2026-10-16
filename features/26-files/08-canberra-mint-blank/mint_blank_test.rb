# frozen_string_literal: true

require "minitest/autorun"
require_relative "mint_blank"

class CanberraMintBlankExpiryTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/mint_blank.yml", __dir__)

  def test_the_blank_is_not_expired_yet
    result = nil
    Multivitamin::Cassettes.play(__dir__, "mint_blank") do
      result = CanberraMintBlank::MintBlank.conduct
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
