# frozen_string_literal: true

require "minitest/autorun"
require_relative "tide_briefing"

class TideBriefingTest < Minitest::Test
  def test_watch_brief_keeps_the_board_and_the_earlier_turn
    result = nil
    Multivitamin::Cassettes.play(__dir__, "tide_briefing") do
      result = PointWilsonTideBoard::TideBriefing.conduct
    end

    assert_includes result.opening, "Alden"
    assert_includes result.opening, "Retort"
    assert_match(/\b6(\.0)?\b/, result.opening)
    assert_includes result.opening, "12:18"

    assert_includes result.follow_up, "Alden"
    assert_match(/09:30|9:30/, result.follow_up)
    assert_match(/lens/i, result.follow_up)

    assert_equal %i[system user assistant user assistant], result.roles
    assert_equal :stop, result.opening_finish
    assert_equal :stop, result.follow_up_finish

    assert_operator result.opening_input_tokens, :>, 0
    assert_operator result.opening_output_tokens, :>, 0
    assert_operator result.follow_up_input_tokens, :>, result.opening_input_tokens
    assert_operator result.follow_up_output_tokens, :>, 0
    assert_equal 0, result.opening_cost
    assert_equal 0, result.follow_up_cost
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/tide_briefing.yml", __dir__))

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
