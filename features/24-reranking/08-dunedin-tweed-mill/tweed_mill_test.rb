# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "tweed_mill"

class DunedinTweedMillPipelineTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/tweed_mill.yml", __dir__)

  def test_embed_then_rerank_puts_loom_three_first
    result = nil
    Multivitamin::Cassettes.play(__dir__, "tweed_mill") do
      result = DunedinTweedMill::TweedMill.conduct
    end

    assert_equal 1, result.index
    assert_includes result.document, "Harris-weight"
    assert_operator result.vector_size, :>, 0
    assert_equal 2, interactions.length
    assert_match(/embeddings|embed/, interactions.fetch(0).dig("request", "uri"))
    assert_match(/rerank/, interactions.fetch(1).dig("request", "uri"))
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end

  def interactions
    YAML.load_file(CASSETTE).fetch("http_interactions")
  end
end
