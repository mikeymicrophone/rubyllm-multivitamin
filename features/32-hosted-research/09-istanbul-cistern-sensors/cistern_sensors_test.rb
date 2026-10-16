# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../support/research_assertions"
require_relative "cistern_sensors"

class IstanbulCisternSensorsTest < Minitest::Test
  include Multivitamin::ResearchAssertions

  CASSETTE = File.expand_path("cassettes/cistern_sensors.yml", __dir__)

  def test_cistern_sensors_research_flow
    card = Multivitamin::Cassettes.play(__dir__, "cistern_sensors") { IstanbulCisternSensors.conduct }
    assert_includes card.fetch(:report), "Basilica Cistern"
    assert_includes card.fetch(:calls), "microsoft_docs_search"
    assert_equal Multivitamin::Models::VERTEXAI_RESEARCH, card.fetch(:agent)
    tools = requests.first.fetch("tools")
    assert_includes tools, { "type" => "google_search" }
    mcp = tools.find { |tool| tool.fetch("type") == "mcp_server" }
    assert_equal ["microsoft_docs_search"], mcp.fetch("allowed_tools")
    refute mcp.key?("require_approval")
  end

  def test_cassette_does_not_carry_a_live_key
    assert_research_credentials_filtered
  end
end
