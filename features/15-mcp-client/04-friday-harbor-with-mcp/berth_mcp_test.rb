# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "berth_mcp"

class FridayHarborMcpWithChatTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/berth_mcp.yml", __dir__)

  def test_with_mcp_connects_the_desk_and_nil_clears_it
    result = nil
    Multivitamin::Cassettes.play(__dir__, "berth_mcp") do
      result = FridayHarborWithMcp::BerthMcp.conduct
    end

    assert_equal "friday_harbor_berth_desk", result.connected_name
    assert result.cleared
    assert_includes result.tool_content, "54 ft"
    assert_includes result.answer, "Kulshan"
    assert_includes result.answer, "54"
    assert_includes result.roles, :tool

    request = request_bodies.fetch(0)
    assert_includes request, '"name":"berth_length"'
    refute_includes request, "54 ft"
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map do |interaction|
      interaction.dig("request", "body", "string")
    end
  end
end
