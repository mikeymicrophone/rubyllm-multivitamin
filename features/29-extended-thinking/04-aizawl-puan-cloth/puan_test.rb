# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "puan"

class AizawlPuanSummarizedTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/puan.yml", __dir__)

  def test_summarized_display_fills_thinking_text
    result = nil
    Multivitamin::Cassettes.play(__dir__, "puan") do
      result = AizawlPuanCloth::PuanCloth.conduct
    end

    assert_includes result.brief, "Lalrin"
    assert_includes result.brief, "10:15"
    refute_nil result.thinking_text
    refute_empty result.thinking_text
    refute_nil result.signature
    refute_empty result.signature
    assert_includes request_body, '"summary":"auto"'
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
