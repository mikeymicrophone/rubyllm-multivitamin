# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "qvevri_clay"

class KutaisiQvevriClayCapstoneTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/qvevri_clay.yml", __dir__)

  def test_the_desk_sends_ttl_key_breakpoint_and_asks_twice
    result = nil
    Multivitamin::Cassettes.play(__dir__, "qvevri_clay") do
      result = KutaisiQvevriClay::QvevriClay.conduct
    end

    assert_includes result.opening, "Nino"
    assert_includes result.opening, "16:20"
    assert_match(/\ANo\b/, result.follow_up)
    assert_equal %i[system user assistant user assistant], result.roles
    assert_kind_of Integer, result.cache_read
    assert_equal 2, interactions.length
    assert_includes request_body(0), '"prompt_cache_key":"kutaisi-qvevri-2026-1016"'
    refute_includes request_body(0), "prompt_cache_options"
    refute_includes request_body(0), "prompt_cache_breakpoint"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def interactions
    YAML.load_file(CASSETTE).fetch("http_interactions")
  end

  def request_body(index)
    interactions.fetch(index).dig("request", "body", "string").to_s
  end
end
