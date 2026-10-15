# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "pilot_context"

class AgentNeahBayPilotContextTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/pilot_context.yml", __dir__)

  def test_the_boat_context_keeps_the_catalog_title_off_the_global_config
    result = nil
    Multivitamin::Cassettes.play(__dir__, "pilot_context") do
      result = NeahBayPilotContext::LadderBrief.conduct
    end

    assert_match(/\AYes\b/, result.brief)
    assert_includes result.brief, "9"
    assert_equal %i[system user assistant], result.roles
    assert_equal NeahBayPilotContext::LadderBrief::GLOBAL_TITLE, result.global_title_after
    assert_equal 120, result.global_timeout_after
    assert_equal 90, result.agent_timeout

    headers = request_headers
    assert_equal [NeahBayPilotContext::LadderBrief::BOAT_TITLE], headers["X-Openrouter-Title"]
    assert_equal [NeahBayPilotContext::LadderBrief::BOAT_URL], headers["Http-Referer"]
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end

  def request_headers
    YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0).fetch("request").fetch("headers")
  end
end
