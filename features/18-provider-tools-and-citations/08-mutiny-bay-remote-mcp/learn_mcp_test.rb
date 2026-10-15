# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "learn_mcp"

class ProviderToolsMutinyBayRemoteMcpTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/learn_mcp.yml", __dir__)

  def test_the_hosted_connector_names_the_learn_page
    result = nil
    Multivitamin::Cassettes.play(__dir__, "learn_mcp") do
      result = MutinyBayRemoteMcp::LearnMcp.conduct
    end

    assert_match(/Mutiny Bay/i, result.brief)
    assert_match(/Alden/i, result.brief)
    assert_match(/device twin/i, result.brief)
    assert_includes result.call_types, "mcp_list_tools"
    assert_includes result.call_types, "mcp_call"
    assert_includes result.call_names, "microsoft_docs_search"
    assert_equal %i[system user assistant], result.roles
    assert_operator result.cost, :>, 0

    request = request_bodies.fetch(0)
    assert_includes request, '"type":"mcp"'
    assert_includes request, '"server_label":"learn"'
    assert_includes request, '"server_url":"https://learn.microsoft.com/api/mcp"'
    assert_includes request, '"require_approval":"never"'
    refute_includes request, '"url":"https://learn.microsoft.com/api/mcp"'
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
