# frozen_string_literal: true

require "minitest/autorun"
require_relative "berth_tool"

class PersistedFridayHarborBerthToolTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/berth_tool.yml", __dir__)

  def test_the_berth_log_keeps_the_tool_call
    result = nil
    Multivitamin::Cassettes.play(__dir__, "berth_tool") do
      result = FridayHarborBerthTool::BerthClerk.conduct
    end

    assert_includes result.tool_content, "54"
    assert_includes result.answer, "54"
    assert_includes result.answer, "Kulshan"
    assert_equal "berth_length", result.tool_name
    assert_equal 1, result.tool_call_count
    assert_equal "RubyLLM::ActiveRecord::ToolCall", result.tool_call_class
    refute result.has_macro
    assert_equal %i[system user assistant tool assistant], result.roles
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
