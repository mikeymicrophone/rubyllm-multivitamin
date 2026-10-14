# frozen_string_literal: true

require "minitest/autorun"
require_relative "gate_schedule"

class GateScheduleTest < Minitest::Test
  def test_the_reused_chat_knows_retort_and_the_fresh_chat_does_not
    result = nil
    Multivitamin::Cassettes.play(__dir__, "gate_schedule") do
      result = BremertonHaulOut::GateSchedule.conduct
    end

    assert_includes result.flattery, "09:15"
    assert_includes result.flattery, "Cape Flattery"
    assert_includes result.retort_on_the_same_chat, "15:05"
    assert_includes result.retort_on_the_same_chat, "Retort"

    assert_includes result.retort_on_a_fresh_chat, "The gate log was not handed over."
    refute_includes result.retort_on_a_fresh_chat, "15:05"

    assert_equal %i[system user assistant user assistant], result.reused_roles
    assert_equal %i[system user assistant], result.fresh_roles
    assert_equal "And the tender Retort?", result.fresh_user_text
    assert result.reused_still_has_schedule
    refute_includes result.fresh_user_text, "Cape Flattery"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/gate_schedule.yml", __dir__))

    refute_match(/sk-or-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
