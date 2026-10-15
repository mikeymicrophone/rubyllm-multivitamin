# frozen_string_literal: true

require "minitest/autorun"
require_relative "weather_loop"

class AgentSmithIslandWeatherLoopTest < Minitest::Test
  def test_ask_later_then_step_until_complete
    result = nil
    Multivitamin::Cassettes.play(__dir__, "weather_loop") do
      result = SmithIslandWeatherLoop::BarometerRound.conduct
    end

    assert result.complete_before_later
    refute result.complete_after_later
    assert_equal "RubyLLM::Chat", result.later_class
    assert_equal :assistant, result.step_role
    assert result.complete_after_step
    assert_nil result.second_step
    assert_includes result.brief, "29.84"
    assert_match(/fall/i, result.brief)
    assert_equal %i[system user assistant], result.roles
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/weather_loop.yml", __dir__))

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
