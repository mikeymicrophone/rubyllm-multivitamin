# frozen_string_literal: true

require "minitest/autorun"
require_relative "vitals_round"

class VitalsRoundTest < Minitest::Test
  def test_stopped_is_the_check_for_a_finished_round
    result = nil
    Multivitamin::Cassettes.play(__dir__, "vitals_round") do
      result = JohannesburgClinicVitals::VitalsRound.conduct
    end

    assert_equal true, result.stopped
    assert_equal :stop, result.finish_reason
    assert_includes result.round, "72"
    assert_includes result.round, "36.8"
    assert_includes result.round, "118"
    assert_includes result.round, "98"
    refute_match(/tomorrow/i, result.round)
    assert_equal %i[system user assistant], result.roles
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/vitals_round.yml", __dir__))

    refute_match(/sk-or-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
