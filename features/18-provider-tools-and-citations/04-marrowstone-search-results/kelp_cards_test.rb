# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "kelp_cards"

class ProviderToolsMarrowstoneSearchResultsTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/kelp_cards.yml", __dir__)

  def test_the_cabinet_returns_json_and_the_watch_hears_the_time
    result = nil
    Multivitamin::Cassettes.play(__dir__, "kelp_cards") do
      result = MarrowstoneSearchResults::KelpCards.conduct
    end

    assert_includes result.brief, "10:46"
    assert_match(/Alden/i, result.brief)
    assert_includes result.tool_content, '"search_results"'
    assert_includes result.tool_content, "Marrowstone kelp ledge card"
    assert_includes result.parsed_titles, "Marrowstone kelp ledge card"
    assert_equal [], result.citations
    assert_equal %i[system user assistant tool assistant], result.roles
    assert_operator result.cost, :>, 0

    request = request_bodies.fetch(0)
    assert_includes request, '"name":"kelp_ledge_cabinet"'
    refute_includes request, "10:46"
  end

  def test_empty_search_results_raise_before_a_request
    error = assert_raises(ArgumentError) { RubyLLM::SearchResults.new }

    assert_match(/at least one result/i, error.message)
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
