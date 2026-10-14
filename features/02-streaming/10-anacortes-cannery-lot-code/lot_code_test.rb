# frozen_string_literal: true

require "minitest/autorun"
require_relative "lot_code"

class LotCodeTest < Minitest::Test
  CODE = AnacortesCanneryLotCode::LotCode::LOT_CODE

  def test_the_lot_code_is_read_from_the_joined_label
    result = nil
    Multivitamin::Cassettes.play(__dir__, "lot_code") do
      result = AnacortesCanneryLotCode::LotCode.conduct
    end

    assert_equal result.speech, result.pieces.join
    assert_includes result.speech, CODE
    assert_operator result.pieces.size, :>, 1
    assert_match(/basket[[:space:]]3/i, result.speech)
    assert_match(/retort[[:space:]]No\.?[[:space:]]2/i, result.speech)

    start = result.speech.index(CODE)
    assert_equal CODE, result.pieces.join[start, CODE.length]
    refute result.pieces.all? { |piece| piece.include?(CODE) }
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/lot_code.yml", __dir__))

    refute_match(/sk-or-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
