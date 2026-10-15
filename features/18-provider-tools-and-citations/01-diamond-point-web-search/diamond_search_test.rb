# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "diamond_search"

class ProviderToolsDiamondPointWebSearchTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/diamond_search.yml", __dir__)

  def test_the_diamond_point_hail_cites_noaa
    result = nil
    Multivitamin::Cassettes.play(__dir__, "diamond_search") do
      result = DiamondPointWebSearch::DiamondSearch.conduct
    end

    assert_match(/Alden/i, result.hail)
    assert_match(/Diamond Point/i, result.hail)
    assert_includes result.call_types, "web_search_call"
    if result.citation_urls.any?
      assert result.citation_urls.all? { |url| url.start_with?("http") }
      assert_equal "RubyLLM::Citation", result.citation_class
    end
    assert_operator result.search_requests, :>=, 1
    assert_equal %i[system user assistant], result.roles
    assert_operator result.cost, :>, 0

    request = request_bodies.fetch(0)
    assert_includes request, '"type":"web_search"'
    assert_includes request, '"model":"gpt-4.1-mini"'
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
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
