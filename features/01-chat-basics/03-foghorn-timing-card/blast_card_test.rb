# frozen_string_literal: true

require "minitest/autorun"
require_relative "blast_card"

class BlastCardTest < Minitest::Test
  def test_low_temperature_keeps_the_card_on_the_slate
    result = nil
    Multivitamin::Cassettes.play(__dir__, "blast_card") do
      result = CapeDisappointmentFoghorn::BlastCard.conduct
    end

    assert_equal 0.0, result.temperature
    assert_includes result.card, "Blast: 2 seconds"
    assert_includes result.card, "Silent: 18 seconds"
    assert_includes result.card, "Horn: diaphone"
    refute_match(/lighthouse tour|Columbia River/i, result.card)
    assert_operator result.card.length, :<, 400
    assert_equal :stop, result.finish_reason
    assert_equal %i[system user assistant], result.roles
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/blast_card.yml", __dir__))

    refute_match(/sk-or-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
