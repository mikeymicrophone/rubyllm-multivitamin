# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "cacao_vectors"

class CacaoDimensionTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/cacao_vectors.yml", __dir__)

  def test_the_pocket_ledger_is_512_wide
    result = nil
    Multivitamin::Cassettes.play(__dir__, "cacao_vectors") do
      result = AbidjanCacaoLot::CacaoVectors.conduct
    end

    assert_equal 1536, result.archive_length
    assert_equal 512, result.pocket_length
    assert_equal "text-embedding-3-small", result.model_id
    assert_equal result.archive_tokens, result.pocket_tokens
    assert_operator result.cost, :>, 0

    archive_request, pocket_request = request_bodies
    refute_includes archive_request, '"dimensions"'
    assert_includes pocket_request, '"dimensions":512'
    assert_equal 2, YAML.load_file(CASSETTE).fetch("http_interactions").length
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map do |interaction|
      interaction.dig("request", "body", "string").to_s
    end
  end
end
