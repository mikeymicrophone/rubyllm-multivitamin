# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "rate_limit"

class RotterdamGoudaWarehouseLimitTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/rate_limit.yml", __dir__)

  def test_the_free_ripening_model_is_rate_limited_once
    result = nil
    Multivitamin::Cassettes.play(__dir__, "rate_limit") do
      result = RotterdamGoudaWarehouse::RateLimit.conduct
    end

    assert_instance_of RubyLLM::RateLimitError, result.error
    assert_equal 429, result.status
    assert_includes result.error.message, "free-models-per-day"
    assert_includes result.body, "429"
    assert_equal 1, interactions.length
    assert_equal 429, interactions.fetch(0).dig("response", "status", "code")
    assert_includes request_body, result.slug
    refute_includes request_body, '"max_retries"'
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end

  def request_body
    interactions.fetch(0).dig("request", "body", "string").to_s
  end

  def interactions
    YAML.load_file(CASSETTE).fetch("http_interactions")
  end
end
