# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "fetch_alias"

class ProviderToolsUselessBayUnknownAliasTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/fetch_alias.yml", __dir__)

  def test_web_fetch_is_refused_and_web_search_still_hails
    result = nil
    Multivitamin::Cassettes.play(__dir__, "fetch_alias") do
      result = UselessBayUnknownAlias::FetchAlias.conduct
    end

    assert_equal "RubyLLM::UnsupportedServerToolError", result.fetch_error
    assert_match(/:web_fetch/, result.fetch_message)
    assert_includes result.known_aliases, "web_search"
    assert_includes result.known_aliases, "file_search"
    assert_includes result.known_aliases, "code_execution"
    assert_includes result.known_aliases, "mcp"
    refute_includes result.known_aliases, "web_fetch"

    assert_match(/Useless Bay/i, result.brief)
    assert_match(/Alden/i, result.brief)
    assert result.citation_urls.any?
    assert_includes result.call_types, "web_search_call"
    assert_operator result.cost, :>, 0

    assert_equal 1, request_bodies.length
    assert_includes request_bodies.fetch(0), '"type":"web_search"'
    refute_includes request_bodies.fetch(0), "web_fetch"
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
