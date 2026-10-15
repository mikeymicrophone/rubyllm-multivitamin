# frozen_string_literal: true

require "minitest/autorun"
require_relative "depot_handover"

class DepotHandoverTest < Minitest::Test
  def test_the_relief_gets_both_boards_and_the_readers
    result = nil
    Multivitamin::Cassettes.play(__dir__, "depot_handover") do
      result = WarsawTramDepot::DepotHandover.conduct
    end

    assert_includes result.brief, "07:05"
    assert_match(/de-icer|deicer|ice/i, result.brief)
    assert_match(/running|yes/i, result.brief)

    assert_match(/locker|paint/i, result.locker)
    assert_includes result.locker, "07:05"
    assert_match(/do not open|closed|no\b/i, result.locker)

    assert_equal %i[system user assistant user assistant], result.roles
    assert_equal :stop, result.brief_finish
    assert_equal :stop, result.locker_finish
    assert_operator result.brief_input_tokens, :>, 0
    assert_operator result.brief_output_tokens, :>, 0
    assert_operator result.locker_input_tokens, :>, result.brief_input_tokens
    assert_operator result.locker_output_tokens, :>, 0
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/depot_handover.yml", __dir__))

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
