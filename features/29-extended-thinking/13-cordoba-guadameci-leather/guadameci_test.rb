# frozen_string_literal: true

require "minitest/autorun"
require_relative "guadameci"

class CordobaGuadameciCapstoneTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/guadameci.yml", __dir__)

  def test_the_follow_up_still_sees_the_standing_order
    result = nil
    Multivitamin::Cassettes.play(__dir__, "guadameci") do
      result = CordobaGuadameciLeather::GuadameciLeather.conduct
    end

    assert_includes result.opening, "Rafael"
    assert_includes result.opening, "08:55"
    assert_match(/\ANo\b/, result.follow_up)
    refute_nil result.opening_thinking
    refute_nil result.opening_signature
    assert_instance_of Integer, result.opening_tokens
    assert_instance_of Integer, result.follow_tokens
    assert_equal %i[system user assistant user assistant], result.roles
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
