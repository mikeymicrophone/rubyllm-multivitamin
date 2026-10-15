# frozen_string_literal: true

require "minitest/autorun"
require_relative "watch_capstone"

class AgentAdmiraltyInletWatchCapstoneTest < Minitest::Test
  def test_the_watch_desk_fills_the_card_then_answers_the_lens
    result = nil
    Multivitamin::Cassettes.play(__dir__, "watch_capstone") do
      result = AdmiraltyInletWatchCapstone::WatchCard.conduct
    end

    parsed = result.parsed
    assert_kind_of Hash, parsed
    assert_includes parsed.fetch("alden_clears"), "10:46"
    assert_includes parsed.fetch("retort_float"), "08:57"
    assert_match(/09:30|9:30/, parsed.fetch("lens_until"))
    assert_equal AdmiraltyInletWatchCapstone::PostedTideBoard::BOARD, result.tool_content
    assert_includes result.follow_up, "Alden"
    assert_includes result.follow_up, "10:46"
    assert_match(/lens/i, result.follow_up)
    assert_includes result.roles, :tool
    assert_equal :assistant, result.roles.last
    assert_operator result.input_tokens, :>, 0
    assert_operator result.cost, :>, 0
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/watch_capstone.yml", __dir__))

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
