# frozen_string_literal: true

require "minitest/autorun"
require_relative "watch_handover"

class WatchHandoverTest < Minitest::Test
  def test_the_relief_gets_both_boards_and_the_readers
    result = nil
    Multivitamin::Cassettes.play(__dir__, "watch_handover") do
      result = PointWilsonNightWatch::WatchHandover.conduct
    end

    assert_includes result.brief, "07:05"
    assert_match(/horn/i, result.brief)
    assert_match(/running|yes/i, result.brief)

    assert_match(/cabinet/i, result.cabinet)
    assert_includes result.cabinet, "07:05"
    assert_match(/do not open|closed|no\b/i, result.cabinet)

    assert_equal %i[system user assistant user assistant], result.roles
    assert_equal :stop, result.brief_finish
    assert_equal :stop, result.cabinet_finish
    assert_operator result.brief_input_tokens, :>, 0
    assert_operator result.brief_output_tokens, :>, 0
    assert_operator result.cabinet_input_tokens, :>, result.brief_input_tokens
    assert_operator result.cabinet_output_tokens, :>, 0
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/watch_handover.yml", __dir__))

    refute_match(/sk-or-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
