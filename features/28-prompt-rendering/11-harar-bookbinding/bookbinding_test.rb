# frozen_string_literal: true

require "minitest/autorun"
require_relative "bookbinding"

class HararBookbindingLambdaTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/bookbinding.yml", __dir__)

  def test_the_display_name_lambda_lands_in_the_system_turn
    result = nil
    Multivitamin::Cassettes.play(__dir__, "bookbinding") do
      result = HararBookbinding::Bookbinding.conduct
    end

    assert_includes result.system, "Zahra"
    assert_includes result.brief, "Zahra"
    assert_includes result.brief, "08:50"
    assert_equal "HararBookbinding::BinderyClerk", result.agent_class
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
