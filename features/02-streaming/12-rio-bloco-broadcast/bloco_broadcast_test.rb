# frozen_string_literal: true

require "minitest/autorun"
require_relative "bloco_broadcast"

class BlocoBroadcastTest < Minitest::Test
  def test_both_schools_hear_the_same_spoken_chunks
    result = nil
    Multivitamin::Cassettes.play(__dir__, "bloco_broadcast") do
      result = RioBlocoBroadcast::RainBroadcast.conduct
    end

    assert_includes result.speech, "Lívia"
    assert_includes result.speech, "45"
    assert_match(/Samb[oó]dromo/i, result.speech)
    assert_equal result.speech, result.pieces.join
    assert_operator result.pieces.size, :>, 1
    assert_equal result.pieces.size, result.broadcasts
    assert_equal result.speech, result.tapes.fetch("Mangueira")
    assert_equal result.speech, result.tapes.fetch("Portela")
    assert_equal result.tapes.fetch("Mangueira"), result.tapes.fetch("Portela")
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/bloco_broadcast.yml", __dir__))

    refute_match(/sk-(?:or-v1-)?[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
