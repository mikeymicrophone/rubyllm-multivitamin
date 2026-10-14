# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "pilot_retries"

class NeahBayRetryKnobTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/pilot_retries.yml", __dir__)

  def test_the_boarding_context_turns_retries_off_and_leaves_the_global_count
    result = nil
    Multivitamin::Cassettes.play(__dir__, "pilot_retries") do
      result = NeahBayRetryKnobs::PilotRetries.conduct
    end

    assert_match(/\AYes\b/, result.ladder)
    assert_includes result.ladder, "9"
    assert_equal NeahBayRetryKnobs::PilotRetries::BOARDING_RETRIES, result.boarding_retries
    assert_equal NeahBayRetryKnobs::PilotRetries::BOARDING_INTERVAL, result.boarding_interval
    assert_equal NeahBayRetryKnobs::PilotRetries::BOARDING_BACKOFF, result.boarding_backoff
    assert_equal NeahBayRetryKnobs::PilotRetries::GLOBAL_RETRIES, result.global_retries
    assert_equal 0.1, result.global_interval
    assert_equal 1, YAML.load_file(CASSETTE).fetch("http_interactions").length
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
