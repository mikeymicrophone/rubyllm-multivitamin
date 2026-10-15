# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "tide_gauge_docs"

class PointWilsonMcpLearnUrlTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/tide_gauge_docs.yml", __dir__)

  def test_the_url_class_exposes_search_and_the_watch_hears_the_title
    result = nil
    Multivitamin::Cassettes.play(__dir__, "tide_gauge_docs") do
      result = PointWilsonLearnUrl::TideGaugeDocs.conduct
    end

    assert_equal "microsoft_learn_docs", result.server_name
    assert result.connected
    assert_includes result.tool_names, "microsoft_docs_search"
    refute_includes result.tool_names, "microsoft_docs_fetch"
    assert_includes result.roles, :tool
    assert_match(/device twin/i, result.tool_content)
    assert_includes result.answer, "Alden"
    assert_match(/device twin/i, result.answer)

    request = openai_bodies.fetch(0)
    assert_includes request, '"name":"microsoft_docs_search"'
    refute_includes request, '"name":"microsoft_docs_fetch"'

    close = YAML.load_file(CASSETTE).fetch("http_interactions").find do |interaction|
      interaction.dig("request", "method") == "delete" &&
        interaction.dig("request", "uri").to_s.include?("learn.microsoft.com")
    end
    assert_equal 405, close.dig("response", "status", "code")
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
    refute_includes cassette, "Bearer sk-"
  end

  def openai_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").filter_map do |interaction|
      body = interaction.dig("request", "body", "string")
      body if interaction.dig("request", "uri").to_s.include?("openai.com")
    end
  end
end
