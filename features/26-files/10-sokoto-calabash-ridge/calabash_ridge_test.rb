# frozen_string_literal: true

require "minitest/autorun"
require_relative "calabash_ridge"

class SokotoCalabashRidgeMissingPurposeTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/calabash_ridge.yml", __dir__)

  def test_omitting_purpose_is_a_bad_request
    result = nil
    Multivitamin::Cassettes.play(__dir__, "calabash_ridge") do
      result = SokotoCalabashRidge::CalabashRidge.conduct
    end

    assert_instance_of RubyLLM::BadRequestError, result.error
    assert_match(/purpose/i, result.error.message)
    assert File.exist?(CASSETTE)
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
