# frozen_string_literal: true

require "minitest/autorun"
require_relative "bay_tool"

class PersistedMedellinEscalatorBayTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/bay_tool.yml", __dir__)

  def test_the_bay_log_keeps_the_tool_call
    result = nil
    Multivitamin::Cassettes.play(__dir__, "bay_tool") do
      result = MedellinEscalatorBay::BayClerk.conduct
    end

    assert_includes result.tool_content, "42"
    assert_includes result.answer, "42"
    assert_includes result.answer, "Candelaria"
    assert_equal "bay_length", result.tool_name
    assert_equal 1, result.tool_call_count
    assert_equal "RubyLLM::ActiveRecord::ToolCall", result.tool_call_class
    refute result.has_macro
    assert_equal %i[system user assistant tool assistant], result.roles
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-(?:or-v1-)?[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
