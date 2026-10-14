# frozen_string_literal: true

require "minitest/autorun"
require_relative "horn_timeout"

class HornHouseTimeoutTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/horn_timeout.yml", __dir__)

  def test_the_horn_context_timeout_does_not_change_the_global_timeout
    result = nil
    Multivitamin::Cassettes.play(__dir__, "horn_timeout") do
      result = CapeDisappointmentTimeout::HornTimeout.conduct
    end

    assert_includes result.slate, "2"
    assert_includes result.slate, "18"
    assert_match(/diaphone/i, result.slate)
    assert_equal CapeDisappointmentTimeout::HornTimeout::HORN_TIMEOUT, result.horn_timeout
    assert_equal CapeDisappointmentTimeout::HornTimeout::GLOBAL_TIMEOUT, result.global_timeout
    refute_equal result.horn_timeout, result.global_timeout
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
