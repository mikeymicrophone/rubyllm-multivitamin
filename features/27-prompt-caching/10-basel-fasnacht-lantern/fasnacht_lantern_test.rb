# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "fasnacht_lantern"

class BaselFasnachtLanternShortPrefixTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/fasnacht_lantern.yml", __dir__)

  def test_a_short_prefix_reports_a_zero_read
    result = nil
    Multivitamin::Cassettes.play(__dir__, "fasnacht_lantern") do
      result = BaselFasnachtLantern::FasnachtLantern.conduct
    end

    assert_includes result.brief, "Elsa"
    assert_includes result.brief, "14:10"
    refute_includes request_body, "prompt_cache_options"
    assert_kind_of Integer, result.cache_read
    assert_equal 0, result.cache_read
    assert_operator result.input_tokens, :<, 200
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
