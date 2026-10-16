# frozen_string_literal: true

require "minitest/autorun"
require_relative "alabaster_policy"

class LuxorAlabasterPolicyTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/alabaster_policy.yml", __dir__)

  def test_the_standing_order_stays_on_both_turns
    result = nil
    Multivitamin::Cassettes.play(__dir__, "alabaster_policy") do
      result = LuxorAlabasterPolicy::AlabasterPolicy.conduct
    end

    assert_includes result.opening, "Nour"
    assert_includes result.opening, "07:15"
    assert_match(/\ANo\b/, result.follow_up)
    assert_equal %i[system user assistant user assistant], result.roles
    assert_operator result.input_tokens, :>, 0
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
