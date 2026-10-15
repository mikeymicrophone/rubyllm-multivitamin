# frozen_string_literal: true

require "minitest/autorun"
require_relative "missing_key"

class TurnPointMissingKeyTest < Minitest::Test
  def test_the_watch_radio_raises_before_any_request
    result = nil
    Multivitamin::Cassettes.play(__dir__, "missing_key") do
      result = TurnPointMissingKey::MissingKey.conduct
    end

    assert_equal "RubyLLM::ConfigurationError", result.error_class
    assert_equal "StandardError", result.superclass
    refute result.caught_as_provider_error
    assert_match(/not configured/i, result.message)
    assert_includes result.message, "openrouter_api_key"
  end
end
