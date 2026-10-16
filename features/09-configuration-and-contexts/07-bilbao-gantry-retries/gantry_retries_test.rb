# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "gantry_retries"

class BilbaoGantryRetryTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/gantry_retries.yml", __dir__)

  def test_the_torque_context_turns_retries_off_and_leaves_the_global_count
    result = nil
    Multivitamin::Cassettes.play(__dir__, "gantry_retries") do
      result = BilbaoGantryRetries::GantryRetries.conduct
    end

    assert_match(/\AYes\b/, result.torque)
    assert_includes result.torque, "420"
    assert_equal BilbaoGantryRetries::GantryRetries::TORQUE_RETRIES, result.boarding_retries
    assert_equal BilbaoGantryRetries::GantryRetries::TORQUE_INTERVAL, result.boarding_interval
    assert_equal BilbaoGantryRetries::GantryRetries::TORQUE_BACKOFF, result.boarding_backoff
    assert_equal BilbaoGantryRetries::GantryRetries::GLOBAL_RETRIES, result.global_retries
    assert_equal 0.1, result.global_interval
    assert_equal 1, YAML.load_file(CASSETTE).fetch("http_interactions").length
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
