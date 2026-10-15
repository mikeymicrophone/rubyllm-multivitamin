# frozen_string_literal: true

require "minitest/autorun"
require_relative "watch_desk"

class PersistedAdmiraltyInletWatchDeskTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/watch_desk.yml", __dir__)

  def test_the_desk_keeps_the_tool_the_model_and_the_follow_up
    result = nil
    Multivitamin::Cassettes.play(__dir__, "watch_desk") do
      result = AdmiraltyInletPersistedWatchDesk::WatchClerk.conduct
    end

    assert_includes result.tool_content, "10:12"
    assert_includes result.tide_answer, "10:12"
    assert_includes result.follow_up, "10:12"
    assert_equal 1, result.tool_call_count
    assert_equal "RubyLLM::ActiveRecord::Model", result.model_class
    assert_operator result.usage_count, :>=, 2
    assert_equal 7, result.entry_count
    assert_equal %i[system user assistant tool assistant user assistant], result.roles
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
