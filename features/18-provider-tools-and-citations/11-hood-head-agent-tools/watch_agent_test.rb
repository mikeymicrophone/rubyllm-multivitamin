# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "watch_agent"

class ProviderToolsHoodHeadAgentToolsTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/watch_agent.yml", __dir__)

  def test_the_agent_hails_noaa_without_a_separate_with_provider_tools
    result = nil
    Multivitamin::Cassettes.play(__dir__, "watch_agent") do
      result = HoodHeadAgentTools::WatchBrief.conduct
    end

    assert_equal "HoodHeadAgentTools::WatchClerk", result.agent_class
    assert_includes HoodHeadAgentTools::WatchClerk.ancestors, RubyLLM::Agent
    assert_equal "RubyLLM::Chat", HoodHeadAgentTools::WatchClerk.chat(**Multivitamin::Models.chat(provider: :openai)).class.name
    assert_equal [{ name: :web_search, options: {} }], result.declared_tools

    assert_match(/Hood Head/i, result.opening)
    assert_match(/Alden/i, result.opening)
    assert result.citation_urls.any?
    assert_includes result.call_types, "web_search_call"
    assert_match(/Alden/i, result.follow_up)
    assert_match(/09:30|9:30/, result.follow_up)
    assert_equal %i[system user assistant user assistant], result.roles
    assert_operator result.cost, :>=, 0

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
