# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "twine_task"

class PortAngelesMcpBackgroundTaskTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/twine_task.yml", __dir__)

  def test_the_ledger_pauses_then_resumes_after_two_checks
    result = nil
    Multivitamin::Cassettes.play(__dir__, "twine_task") do
      result = PortAngelesMcpTasks::TwineTask.conduct
    end

    assert result.awaited
    assert_equal :working, result.status_after_first
    assert_match(/Spooling/, result.status_message)
    assert result.done_after_second
    assert_includes result.tool_content, "14 spools"
    assert_includes result.answer, "14"
    assert_includes result.roles, :tool
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
