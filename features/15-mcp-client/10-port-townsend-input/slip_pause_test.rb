# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "slip_pause"

class PortTownsendMcpInputPauseTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/slip_pause.yml", __dir__)

  def test_the_slip_question_pauses_until_the_watch_answers
    result = nil
    Multivitamin::Cassettes.play(__dir__, "slip_pause") do
      result = PortTownsendMcpInput::SlipPause.conduct
    end

    assert result.awaited
    assert_match(/slip/i, result.message)
    assert_equal %w[A B], result.choices
    assert_includes result.tool_content, "slip A"
    assert_includes result.answer, "Chetzemoka"
    assert_includes result.roles, :tool
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
