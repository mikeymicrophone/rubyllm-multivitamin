# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "elk_ford"

class ElkFordTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/elk_ford.yml", __dir__)

  def test_the_ford_stays_closed_then_opens
    result = nil
    Multivitamin::Cassettes.play(__dir__, "elk_ford") do
      result = DuckabushChoiceNoneThenAuto::FordWatch.conduct
    end

    refute_includes result.closed_roles, :tool
    refute_includes result.closed_answer, "2.4"
    assert_includes result.tools_still_registered, "elk_ford_depth"
    assert_equal DuckabushChoiceNoneThenAuto::ElkFordDepth::CARD, result.tool_content
    assert_includes result.open_answer, "2.4"
    assert_includes result.open_answer, "wapiti"
    assert_includes result.roles, :tool

    bodies = YAML.load_file(CASSETTE).fetch("http_interactions").map { |interaction| interaction.dig("request", "body", "string") }
    assert_includes bodies.fetch(0), '"tool_choice":"none"'
    refute_includes bodies.fetch(0), "2.4 ft"
    opened = bodies.find { |body| body.include?("read the elk ford staff") }
    refute_nil opened
    refute_includes opened, '"tool_choice":"none"'
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
