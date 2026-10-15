# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "yaml"
require_relative "tidal_race"

class AgatePassTidalRaceCacheTokensTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/tidal_race.yml", __dir__)

  def test_cache_buckets_are_not_coerced_and_thinking_is_reported
    result = nil
    Multivitamin::Cassettes.play(__dir__, "tidal_race") do
      result = AgatePassTidalRace::TidalRace.conduct
    end

    assert_includes result.brief, "Kitsap"
    assert_includes result.brief, "5.2"
    assert_operator result.input_tokens, :>, 0
    assert_operator result.output_tokens, :>, 0
    assert_operator result.thinking_tokens, :>, 0

    refute_equal true, result.cache_read_nil
    refute_equal true, result.cache_write_nil
    assert_equal 0, result.cache_read
    assert_equal 0, result.cache_write

    details = JSON.parse(response_body).dig("usage", "prompt_tokens_details") || {}
    assert_equal 0, details.fetch("cached_tokens")
    assert_equal 0, details.fetch("cache_write_tokens")
    assert_equal details.fetch("cached_tokens"), result.cache_read
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end

  def response_body
    YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0).dig("response", "body", "string")
  end
end
