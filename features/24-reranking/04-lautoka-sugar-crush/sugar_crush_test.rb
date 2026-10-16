# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "sugar_crush"

class LautokaSugarCrushTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/sugar_crush.yml", __dir__)

  def test_the_overnight_crush_lands_first
    result = nil
    Multivitamin::Cassettes.play(__dir__, "sugar_crush") do
      result = LautokaSugarCrush::SugarCrush.conduct
    end

    assert_equal 1, result.index
    assert_includes result.document, "mill 2"
    assert_includes result.model, "rerank-2.5-lite"
    assert_includes request_body, "voyageai/rerank-2.5-lite"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end

  def request_body
    YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0).dig("request", "body", "string").to_s
  end
end
