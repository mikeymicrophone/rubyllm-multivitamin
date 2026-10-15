# frozen_string_literal: true

require "minitest/autorun"
require_relative "heat_lot"

class HeatLotTest < Minitest::Test
  CODE = SheffieldHeatLot::HeatLot::LOT_CODE

  def test_the_lot_code_is_read_from_the_joined_label
    result = nil
    Multivitamin::Cassettes.play(__dir__, "heat_lot") do
      result = SheffieldHeatLot::HeatLot.conduct
    end

    assert_equal result.speech, result.pieces.join
    assert_includes result.speech, CODE
    assert_operator result.pieces.size, :>, 1
    assert_match(/rack[[:space:]]3/i, result.speech)
    assert_match(/furnace[[:space:]]No\.?[[:space:]]2/i, result.speech)

    start = result.speech.index(CODE)
    assert_equal CODE, result.pieces.join[start, CODE.length]
    refute result.pieces.any? { |piece| piece.include?(CODE) }
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/heat_lot.yml", __dir__))

    refute_match(/sk-(?:or-v1-)?[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
