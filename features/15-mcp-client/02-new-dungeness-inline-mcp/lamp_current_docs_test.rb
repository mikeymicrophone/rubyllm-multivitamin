# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "lamp_current_docs"

class NewDungenessMcpInlineLearnTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/lamp_current_docs.yml", __dir__)

  def test_inline_mcp_takes_a_url_and_the_lens_hears_the_page
    result = nil
    Multivitamin::Cassettes.play(__dir__, "lamp_current_docs") do
      result = NewDungenessInlineMcp::LampCurrentDocs.conduct
    end

    assert_equal "learn_microsoft", result.server_name
    assert_includes result.roles, :tool
    assert_match(/metric/i, result.tool_content)
    assert_match(/Fresnel|lamp/i, result.answer)

    request = openai_bodies.fetch(0)
    assert_includes request, '"name":"microsoft_docs_search"'
    assert_includes request, '"name":"microsoft_docs_fetch"'
    assert_includes request, '"name":"microsoft_code_sample_search"'
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def openai_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").filter_map do |interaction|
      body = interaction.dig("request", "body", "string")
      body if interaction.dig("request", "uri").to_s.include?("openai.com")
    end
  end
end
