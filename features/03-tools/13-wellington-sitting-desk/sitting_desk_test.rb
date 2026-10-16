# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "sitting_desk"

class SittingDeskTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/sitting_desk.yml", __dir__)

  def test_the_desk_picks_a_board_then_stops_on_the_chit
    result = nil
    Multivitamin::Cassettes.play(__dir__, "sitting_desk") do
      result = WellingtonSittingDesk::SittingDesk.conduct
    end

    assert_includes result.sitting_answer, "10:12"
    assert_includes result.bell_answer, "3 seconds"
    assert_includes result.chit, "Relief chit"
    assert_includes result.tool_contents, WellingtonSittingDesk::PostedSittingBoard.new.execute
    assert_includes result.tool_contents, WellingtonSittingDesk::PostedBellCard.new.execute
    assert_includes result.tool_contents, WellingtonSittingDesk::ReliefHandoff.new.execute
    refute_includes result.tool_contents.join("\n"), "Lights burning"
    assert_equal :tool, result.roles.last
    assert_equal :assistant, result.roles[-2]
    refute result.settled
    assert_equal %w[posted_sitting_board posted_bell_card relief_handoff], result.called_boards

    bodies = YAML.load_file(CASSETTE).fetch("http_interactions").map { |interaction| interaction.dig("request", "body", "string") }
    assert_includes bodies.fetch(0), "posted_sitting_board"
    assert_includes bodies.fetch(0), "posted_bell_card"
    assert_includes bodies.fetch(0), "gallery_latch"
    refute_includes bodies.fetch(0), "relief_handoff"
    refute_includes bodies.fetch(0), "10:12"

    bell_request = bodies.find { |body| body.include?("whether the bells are running") }
    assert_includes bell_request, "10:12"
    refute_includes bell_request, "relief_handoff"

    handoff_request = bodies.find { |body| body.include?('"name":"relief_handoff"') }
    assert_includes handoff_request, '"tool_choice":{"type":"function","name":"relief_handoff"}'
    assert_equal bodies.last, handoff_request
  end

  def test_halt_is_not_a_tool_method
    refute WellingtonSittingDesk::ReliefHandoff.method_defined?(:halt)
    refute WellingtonSittingDesk::ReliefHandoff.private_method_defined?(:halt)
    refute defined?(RubyLLM::Tool::Halt)
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
    refute_includes cassette, "Bearer sk-"
  end
end
