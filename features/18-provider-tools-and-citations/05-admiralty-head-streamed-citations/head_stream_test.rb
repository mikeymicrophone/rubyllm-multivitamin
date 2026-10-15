# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "head_stream"

class ProviderToolsAdmiraltyHeadStreamedCitationsTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/head_stream.yml", __dir__)

  def test_citations_arrive_on_chunks_and_on_the_completed_hail
    result = nil
    Multivitamin::Cassettes.play(__dir__, "head_stream") do
      result = AdmiraltyHeadStreamedCitations::HeadStream.conduct
    end

    assert_match(/Admiralty Head/i, result.speech)
    assert_match(/Alden/i, result.speech)
    assert result.citations.any?
    assert_operator result.chunks_with_citations, :>=, 1
    assert_equal result.citations.map(&:url).compact.uniq.sort, result.chunk_citation_urls.sort
    assert_includes result.call_types, "web_search_call"
    assert_operator result.search_requests, :>=, 1
    assert_operator result.cost, :>, 0

    request = request_bodies.fetch(0)
    assert_includes request, '"stream":true'
    assert_includes request, '"type":"web_search"'
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
