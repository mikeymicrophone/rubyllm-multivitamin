# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "berth_fallbacks"

class AgentFridayHarborBerthFallbackTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/berth_fallbacks.yml", __dir__)

  def test_default_fallbacks_skip_a_400_and_on_reaches_openai
    result = nil
    Multivitamin::Cassettes.play(__dir__, "berth_fallbacks") do
      result = FridayHarborBerthFallbacks::SlipSheet.conduct
    end

    assert_instance_of RubyLLM::BadRequestError, result.default_error
    assert_equal 400, result.default_status
    assert_includes result.default_error.message, FridayHarborBerthFallbacks::UNLISTED
    assert_includes result.rescued, "14"
    assert_match(/Kalakala/i, result.rescued)
    assert_includes result.fallback_model, "gpt-4.1-mini"
    assert_equal %i[system user assistant], result.roles
    refute_includes RubyLLM::Fallback::DEFAULT_ERRORS, RubyLLM::BadRequestError
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
