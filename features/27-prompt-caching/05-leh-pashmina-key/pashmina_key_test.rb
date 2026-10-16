# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "pashmina_key"

class LehPashminaKeyTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/pashmina_key.yml", __dir__)

  def test_the_cache_key_is_on_the_wire
    result = nil
    Multivitamin::Cassettes.play(__dir__, "pashmina_key") do
      result = LehPashminaKey::PashminaKey.conduct
    end

    assert_includes result.brief, "Tsering"
    assert_includes result.brief, "10:05"
    assert_includes request_body, '"prompt_cache_key":"leh-pashmina-2026-1016"'
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
