# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "attribution"

class PointWilsonAttributionTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/attribution.yml", __dir__)

  def test_the_cassette_keeps_station_attribution_and_the_watch_header
    result = nil
    Multivitamin::Cassettes.play(__dir__, "attribution") do
      result = PointWilsonAttribution::Attribution.conduct
    end

    assert_includes result.brief, "Alden"
    assert_includes result.brief, "10:46"
    assert_equal PointWilsonAttribution::Attribution::ATTEMPTED_REFERER, result.headers["HTTP-Referer"]
    assert_equal PointWilsonAttribution::Attribution::WATCH_HEADER, result.headers["X-Point-Wilson-Watch"]

    headers = request_headers
    assert_equal [PointWilsonAttribution::Attribution::STATION_URL], headers["Http-Referer"]
    refute_includes Array(headers["Http-Referer"]), PointWilsonAttribution::Attribution::ATTEMPTED_REFERER
    assert_equal [PointWilsonAttribution::Attribution::STATION_TITLE], headers["X-Openrouter-Title"]
    assert_equal [PointWilsonAttribution::Attribution::WATCH_HEADER], headers["X-Point-Wilson-Watch"]
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end

  def request_headers
    YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0).fetch("request").fetch("headers")
  end
end
