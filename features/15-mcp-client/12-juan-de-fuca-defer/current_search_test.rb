# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "current_search"

class JuanDeFucaMcpDeferredSearchTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/current_search.yml", __dir__)

  def test_deferred_tools_stay_listed_and_the_gate_is_found
    result = nil
    Multivitamin::Cassettes.play(__dir__, "current_search") do
      result = JuanDeFucaMcpDefer::CurrentSearch.conduct
    end

    assert_includes result.deferred_names, "current_gate"
    assert_operator result.deferred_names.size, :>=, 8
    assert_equal result.deferred_names.sort, result.offered_names.sort
    assert_includes result.tool_content, "2.8 kn"
    assert_includes result.answer, "2.8"
    assert_match(/Race Rocks/, result.answer)

    request = request_bodies.fetch(0)
    assert_includes request, '"model":"gpt-5.4-mini"'
    assert_includes request, "defer_loading"
    assert_includes request, '"type":"tool_search"'
    assert_includes request, "current_gate"
    refute_includes request, "tool_search_call"

    follow_up = request_bodies.find { |body| body.include?("tool_search_call") }
    assert follow_up
    assert_includes follow_up, '"type":"tool_search_output"'
    assert_includes follow_up, "2.8 kn"
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
