# frozen_string_literal: true

require "minitest/autorun"
require_relative "cancel_log"

class PersistedJuanDeFucaCancelLogTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/cancel_log.yml", __dir__)

  def test_cancel_clears_the_blank_assistant_row
    result = nil
    Multivitamin::Cassettes.play(__dir__, "cancel_log") do
      result = JuanDeFucaCancelLog::ChartClerk.conduct
    end

    assert_equal 2, result.spoken.size
    assert_equal RubyLLM::CancelledError, result.error_class
    assert_equal StandardError, result.error_parent
    refute_operator RubyLLM::CancelledError, :<, RubyLLM::Error
    assert result.cancelled_during
    assert_equal %i[system user], result.roles
    assert_equal 0, result.assistant_count
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
