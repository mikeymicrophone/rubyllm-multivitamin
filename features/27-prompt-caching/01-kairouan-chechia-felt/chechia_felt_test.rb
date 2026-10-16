# frozen_string_literal: true

require "minitest/autorun"
require_relative "chechia_felt"

class KairouanChechiaFeltTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/chechia_felt.yml", __dir__)

  def test_the_standing_order_stays_on_both_turns
    result = nil
    Multivitamin::Cassettes.play(__dir__, "chechia_felt") do
      result = KairouanChechiaFelt::ChechiaFelt.conduct
    end

    assert_includes result.opening, "Hamza"
    assert_includes result.opening, "08:25"
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
