# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "lagoon_store"

class ProviderToolsLagoonPointFileSearchTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/lagoon_store.yml", __dir__)

  def test_the_store_cites_the_lagoon_point_card
    result = nil
    Multivitamin::Cassettes.play(__dir__, "lagoon_store") do
      result = LagoonPointFileSearch::LagoonStore.conduct
    end

    assert_match(/vector_store_ids/i, result.missing_ids_error)
    assert_includes result.brief, "10:46"
    assert_match(/Alden/i, result.brief)
    assert_match(/Lagoon Point/i, result.brief)
    assert_includes result.citation_titles, "lagoon-point-card.txt"
    assert result.citation_source_ids.any? { |id| id.to_s.start_with?("file-") }
    assert_includes result.call_types, "file_search_call"
    assert_operator result.cost, :>, 0

    bodies = request_bodies
    assert(bodies.any? { |body| body.include?('"type":"file_search"') && !body.include?("vector_store_ids") })
    assert(bodies.any? { |body| body.include?('"type":"file_search"') && body.include?("vector_store_ids") })
    assert(uris.any? { |uri| uri.end_with?("/vector_stores") })
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    interactions.map { |interaction| interaction.dig("request", "body", "string").to_s }
  end

  def uris
    interactions.map { |interaction| interaction.dig("request", "uri").to_s }
  end

  def interactions
    YAML.load_file(CASSETTE).fetch("http_interactions")
  end
end
