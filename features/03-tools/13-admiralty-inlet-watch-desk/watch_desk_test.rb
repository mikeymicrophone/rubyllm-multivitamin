# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "watch_desk"

class WatchDeskTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/watch_desk.yml", __dir__)

  def test_the_desk_picks_a_board_then_stops_on_the_chit
    result = nil
    Multivitamin::Cassettes.play(__dir__, "watch_desk") do
      result = AdmiraltyInletWatchDesk::WatchDesk.conduct
    end

    assert_includes result.tide_answer, "10:12"
    assert_includes result.horn_answer, "3 seconds"
    assert_includes result.chit, "Relief chit"
    assert_includes result.tool_contents, AdmiraltyInletWatchDesk::PostedTideBoard.new.execute
    assert_includes result.tool_contents, AdmiraltyInletWatchDesk::PostedHornCard.new.execute
    assert_includes result.tool_contents, AdmiraltyInletWatchDesk::ReliefHandoff.new.execute
    refute_includes result.tool_contents.join("\n"), "Lamp burning"
    assert_equal :tool, result.roles.last
    assert_equal :assistant, result.roles[-2]
    refute result.settled

    bodies = YAML.load_file(CASSETTE).fetch("http_interactions").map { |interaction| interaction.dig("request", "body", "string") }
    assert_includes bodies.fetch(0), "posted_tide_board"
    assert_includes bodies.fetch(0), "posted_horn_card"
    assert_includes bodies.fetch(0), "lens_cabinet_latch"
    refute_includes bodies.fetch(0), "relief_handoff"
    refute_includes bodies.fetch(0), "10:12"

    horn_request = bodies.find { |body| body.include?("whether the horn is running") }
    assert_includes horn_request, "10:12"
    refute_includes horn_request, "relief_handoff"

    handoff_request = bodies.find { |body| body.include?('"name":"relief_handoff"') }
    assert_includes handoff_request, '"tool_choice":{"type":"function","name":"relief_handoff"}'
    assert_equal bodies.last, handoff_request
  end

  def test_halt_is_not_a_tool_method
    refute AdmiraltyInletWatchDesk::ReliefHandoff.method_defined?(:halt)
    refute AdmiraltyInletWatchDesk::ReliefHandoff.private_method_defined?(:halt)
    refute defined?(RubyLLM::Tool::Halt)
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
    refute_includes cassette, "Bearer sk-"
  end
end
