# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "horn_latch"

class HornLatchTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/horn_latch.yml", __dir__)

  def test_the_range_card_runs_while_the_horn_waits
    result = nil
    Multivitamin::Cassettes.play(__dir__, "horn_latch") do
      result = BangorHornLatchCapstone::DutyOfficer.conduct
    end

    assert result.card_read_while_waiting
    refute result.horn_sounded_while_waiting
    assert result.awaiting
    assert_equal %w[sound_the_horn], result.pending_names
    assert_includes result.pending_error, "sound_the_horn"
    assert result.horn_sounded
    refute_nil result.horn_call_id
    assert_includes result.tool_contents, BangorHornLatchCapstone::PostedRangeCard::CARD
    assert_includes result.tool_contents.join("\n"), "4 seconds"
    refute_includes result.tool_contents.join("\n"), "Restricted-area"
    assert_includes result.answer, "Kentucky"
    assert_includes result.answer, "07:40"
    assert_includes result.answer, "4"
    assert_includes result.follow_up, "Kentucky"
    assert_includes result.roles, :tool

    bodies = YAML.load_file(CASSETTE).fetch("http_interactions").map { |interaction| interaction.dig("request", "body", "string") }
    first = bodies.fetch(0)
    assert_includes first, "posted_range_card"
    assert_includes first, "sound_the_horn"
    assert_includes first, "restricted_gate_log"
    refute_includes first, "07:40"
    follow = bodies.find { |body| body.include?("whether the Kentucky still leaves") }
    refute_nil follow
    assert_includes follow, "07:40"
    assert_includes follow, "4 seconds"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
