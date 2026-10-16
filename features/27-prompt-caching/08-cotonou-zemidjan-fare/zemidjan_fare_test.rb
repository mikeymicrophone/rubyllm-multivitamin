# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "zemidjan_fare"

class CotonouZemidjanFareRailsTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/zemidjan_fare.yml", __dir__)

  def test_the_fare_log_keeps_the_cache_ttl
    result = nil
    Multivitamin::Cassettes.play(__dir__, "zemidjan_fare") do
      result = CotonouZemidjanFare::FareClerk.conduct
    end

    assert_includes result.brief, "Koffi"
    assert_includes result.brief, "06:40"
    assert result.cache_until_here
    assert_equal "1h", result.cache_ttl
    assert_equal "1h", result.reloaded_ttl
    assert_equal 1, result.system_count
    assert_includes request_body, "prompt_cache_breakpoint"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_body
    YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0).dig("request", "body", "string").to_s
  end
end
