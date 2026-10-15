# frozen_string_literal: true

require "minitest/autorun"
require_relative "sill_rescue"

class AgentBremertonSillRescueTest < Minitest::Test
  def test_rescue_from_swallows_on_the_instance_and_chat_still_raises
    result = nil
    Multivitamin::Cassettes.play(__dir__, "sill_rescue") do
      result = BremertonSillRescue::SillCard.conduct
    end

    assert_includes result.rescued, "4.2"
    assert_includes result.rescued, "RubyLLM::BadRequestError"
    assert_equal "BremertonSillRescue::SillClerk", result.instance_class
    assert_equal "RubyLLM::Chat", result.chat_class
    assert_equal "RubyLLM::BadRequestError", result.chat_error_class
    assert_equal 400, result.chat_status
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/sill_rescue.yml", __dir__))

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
