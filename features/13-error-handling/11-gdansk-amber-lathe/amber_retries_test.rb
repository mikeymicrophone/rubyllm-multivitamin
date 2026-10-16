# frozen_string_literal: true

require "minitest/autorun"
require_relative "amber_retries"

class GdanskAmberLatheRetryTest < Minitest::Test
  def test_the_dead_circuit_is_tried_three_times_then_times_out
    result = nil
    Multivitamin::Cassettes.play(__dir__, "amber_retries") do
      GdanskAmberLathe::AmberRetries.ignore_loopback!
      result = GdanskAmberLathe::AmberRetries.conduct
    end

    assert_instance_of Faraday::TimeoutError, result.error
    refute result.is_llm_error
    assert_equal 3, result.hits
    refute File.exist?(File.expand_path("cassettes/amber_retries.yml", __dir__))
    refute_match(/127\.0\.0\.1/, RubyLLM.config.openrouter_api_base.to_s)
    refute_includes RubyLLM::Transport::Connection.send(:retry_exceptions),
                    RubyLLM::ContextLengthExceededError
  end
end
