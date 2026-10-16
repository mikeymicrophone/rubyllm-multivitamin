# frozen_string_literal: true

require "minitest/autorun"
require_relative "terrace_checkpoint"

class CuscoTerraceCheckpointTest < Minitest::Test
  def test_terrace_cursor_survives_interruption
    result = Multivitamin::Cassettes.play(__dir__, "terrace_checkpoint") { CuscoTerraceCheckpoint.conduct }

    assert_equal ["terrace_turns", 1], result.fetch(:cursor)
    assert_equal 1, result.fetch(:resumed_jobs)
    assert result.fetch(:complete)
    assert_equal 2, result.fetch(:assistants)
    assert_equal 1, result.fetch(:tool_results)
    assert_includes result.fetch(:brief), "Qenqo"
    assert_includes result.fetch(:brief), "07:10"
  end

  def test_cassette_has_no_live_key
    cassette = File.binread(File.join(__dir__, "cassettes/terrace_checkpoint.yml"))
    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
