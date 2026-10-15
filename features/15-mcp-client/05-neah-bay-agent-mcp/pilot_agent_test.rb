# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "pilot_agent"

class NeahBayMcpAgentMacroTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/pilot_agent.yml", __dir__)

  def test_the_agent_mcp_macro_connects_the_ladder_desk
    result = nil
    Multivitamin::Cassettes.play(__dir__, "pilot_agent") do
      result = NeahBayAgentMcp::PilotAgent.conduct
    end

    assert_equal %w[neah_bay_pilot_desk], result.server_names
    assert_includes result.tool_content, "06:40"
    assert_includes result.answer, "Makah"
    assert_includes result.answer, "06:40"
    assert_includes result.roles, :tool

    request = request_bodies.fetch(0)
    assert_includes request, '"name":"pilot_ladder"'
    refute_includes request, "06:40"
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
