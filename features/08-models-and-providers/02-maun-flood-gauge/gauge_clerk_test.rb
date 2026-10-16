# frozen_string_literal: true

require "minitest/autorun"
require_relative "gauge_clerk"

class MaunFloodGaugeClerkTest < Minitest::Test
  def test_find_reads_function_calling_and_the_gauge_window
    result = nil
    Multivitamin::Cassettes.play(__dir__, "gauge_clerk") do
      result = MaunFloodGauge::GaugeClerk.conduct
    end

    assert_equal "gpt-4.1-mini", result.id
    assert_equal "openai", result.provider
    assert_equal "gpt-mini", result.family
    assert_equal :chat, result.type
    assert_equal 1_047_576, result.context_window
    assert_equal 32_768, result.max_output_tokens
    assert result.function_calling
    assert result.vision
    assert result.structured_output
    assert_equal 0.4, result.input_price
    assert_equal 1.6, result.output_price
    assert_kind_of String, result.name
    refute_empty result.name
  end
end
