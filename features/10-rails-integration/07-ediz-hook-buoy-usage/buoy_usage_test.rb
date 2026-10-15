# frozen_string_literal: true

require "minitest/autorun"
require_relative "buoy_usage"

class PersistedEdizHookBuoyUsageTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/buoy_usage.yml", __dir__)

  def test_the_usage_row_matches_the_reply
    result = nil
    Multivitamin::Cassettes.play(__dir__, "buoy_usage") do
      result = EdizHookBuoyUsage::BuoyTender.conduct
    end

    assert_includes result.brief, "2"
    assert_match(/12(\.4)?/, result.brief)
    assert_equal 1, result.usage_count
    assert_equal "succeeded", result.usage_status
    assert_equal result.message_input, result.usage_input
    assert_equal result.message_input, result.chat_input
    assert_operator result.usage_input, :>, 0
    assert_operator result.usage_output, :>, 0
    assert_equal %i[system user assistant], result.roles
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
