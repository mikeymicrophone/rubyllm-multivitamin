# frozen_string_literal: true

require "minitest/autorun"
require_relative "current_halt"

class TurnPointCurrentHaltCancelledUsageTest < Minitest::Test
  def test_the_cancelled_attempt_stays_on_the_chat_ledger
    result = nil
    Multivitamin::Cassettes.play(__dir__, "current_halt") do
      result = TurnPointCurrentHalt::CurrentHalt.conduct
    end

    assert_instance_of RubyLLM::CancelledError, result.error
    assert_equal 2, result.spoken.size
    assert_equal %i[system user], result.roles
    assert_equal :cancelled, result.attempt_status
    assert_equal 1, result.attempt_count
    assert_equal 0, result.message_token_sum
    assert_nil result.chat_input
    assert_nil result.chat_output
    assert_nil result.attempt_input
    assert_nil result.attempt_reported
    assert_equal 0, result.chat_cost
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/current_halt.yml", __dir__))

    refute_match(/sk-or-/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
