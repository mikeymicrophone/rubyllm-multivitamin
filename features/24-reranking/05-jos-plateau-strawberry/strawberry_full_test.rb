# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "strawberry_full"

class JosPlateauStrawberryFullTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/strawberry_full.yml", __dir__)

  def test_the_full_slug_ranks_bed_four
    result = nil
    Multivitamin::Cassettes.play(__dir__, "strawberry_full") do
      result = JosPlateauStrawberry::StrawberryFull.conduct
    end

    assert_equal 1, result.index
    assert_includes result.document, "ripe"
    assert_includes result.model, "rerank-2.5"
    assert_includes request_body, "voyageai/rerank-2.5"
    refute_includes request_body, "rerank-2.5-lite"
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
