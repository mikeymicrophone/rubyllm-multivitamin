# frozen_string_literal: true

require "minitest/autorun"
require_relative "buoy_chat_model"

class AgentEdizHookBuoyChatModelTest < Minitest::Test
  def test_create_persists_the_buoy_log_and_the_voltage
    result = nil
    Multivitamin::Cassettes.play(__dir__, "buoy_chat_model") do
      result = EdizHookBuoyChatModel::BatteryCard.conduct
    end

    assert result.persisted
    assert_equal "EdizHookBuoyChatModel::BuoyLog", result.record_class
    assert_includes result.brief, "12.6"
    assert_match(/buoy 2/i, result.brief)
    assert_equal 3, result.entry_count
    assert_equal %i[system user assistant], result.roles
    assert_equal "gpt-4.1-mini", result.model_id
    assert_equal "openai", result.provider
  end

  def test_create_without_chat_model_raises
    clerk = Class.new(RubyLLM::Agent)
    error = assert_raises(ArgumentError) { clerk.create! }
    assert_match(/chat_model/, error.message)
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/buoy_chat_model.yml", __dir__))

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
