# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "citations_off"

class ProviderToolsDoubleBluffCitationsOffTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/citations_off.yml", __dir__)

  def test_search_citations_arrive_after_document_citations_are_off
    result = nil
    Multivitamin::Cassettes.play(__dir__, "citations_off") do
      result = DoubleBluffCitationsOff::CitationsOff.conduct
    end

    assert_match(/true or false/i, result.nil_error)
    assert_equal false, result.citations_flag
    assert_match(/Double Bluff/i, result.brief)
    assert_match(/Alden/i, result.brief)
    assert result.citation_urls.any?
    assert_includes result.call_types, "web_search_call"
    assert_operator result.cost, :>, 0

    request = request_bodies.fetch(0)
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
