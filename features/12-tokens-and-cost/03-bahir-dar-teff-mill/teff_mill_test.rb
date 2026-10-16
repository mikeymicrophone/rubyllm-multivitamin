# frozen_string_literal: true

require "minitest/autorun"
require_relative "teff_mill"

class BahirDarTeffMillTotalsTest < Minitest::Test
  def test_chat_tokens_sum_the_two_mill_questions
    result = nil
    Multivitamin::Cassettes.play(__dir__, "teff_mill") do
      result = BahirDarTeffMill::TeffMill.conduct
    end

    assert_match(/1,?240/, result.count_brief)
    assert_match(/teff/i, result.count_brief)
    assert_match(/09:00|9:00/, result.gate_brief)
    assert_equal %i[system user assistant user assistant], result.roles

    assert_operator result.opening_input, :>, 0
    assert_operator result.follow_up_input, :>, result.opening_input
    assert_equal result.opening_input + result.follow_up_input, result.chat_input
    assert_operator result.chat_output, :>, 0
    assert_equal 0, result.chat_cost
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/teff_mill.yml", __dir__))

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
