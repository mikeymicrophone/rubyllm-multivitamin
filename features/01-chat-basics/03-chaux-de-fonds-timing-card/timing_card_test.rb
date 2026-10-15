# frozen_string_literal: true

require "minitest/autorun"
require_relative "timing_card"

class TimingCardTest < Minitest::Test
  def test_low_temperature_keeps_the_card_on_the_slate
    result = nil
    Multivitamin::Cassettes.play(__dir__, "timing_card") do
      result = ChauxDeFondsChronometer::TimingCard.conduct
    end

    assert_equal 0.0, result.temperature
    assert_includes result.card, "Beat: 18000 bph"
    assert_includes result.card, "Amplitude: 270 degrees"
    assert_includes result.card, "Escapement: Swiss lever"
    refute_match(/museum tour|Jura/i, result.card)
    assert_operator result.card.length, :<, 400
    assert_equal :stop, result.finish_reason
    assert_equal %i[system user assistant], result.roles
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/timing_card.yml", __dir__))

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
