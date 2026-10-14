# frozen_string_literal: true

require "minitest/autorun"
require_relative "ladder_steps"

class LadderStepsTest < Minitest::Test
  CHECKS = ["side ropes", "wooden steps", "spreaders", "manropes"].freeze

  def test_the_steps_stay_in_order_after_the_stream_is_joined
    result = nil
    Multivitamin::Cassettes.play(__dir__, "ladder_steps") do
      result = NeahBayLadderSteps::LadderSteps.conduct
    end

    assert_equal result.speech, result.pieces.join
    assert_operator result.pieces.size, :>, 1
    assert result.same_message
    assert_equal :assistant, result.role
    assert_equal %i[system user assistant], result.roles
    assert_equal :stop, result.finish_reason
    assert_equal true, result.stopped

    positions = CHECKS.map { |check| result.speech.downcase.index(check) }
    assert positions.all? { |position| position }
    assert_equal positions.sort, positions
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/ladder_steps.yml", __dir__))

    refute_match(/sk-or-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
