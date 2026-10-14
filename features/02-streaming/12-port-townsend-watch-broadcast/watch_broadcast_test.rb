# frozen_string_literal: true

require "minitest/autorun"
require_relative "watch_broadcast"

class WatchBroadcastTest < Minitest::Test
  def test_both_stations_hear_the_same_spoken_chunks
    result = nil
    Multivitamin::Cassettes.play(__dir__, "watch_broadcast") do
      result = PortTownsendWatchBroadcast::GaleBroadcast.conduct
    end

    assert_includes result.speech, "Alden"
    assert_includes result.speech, "45"
    assert_match(/Admiralty[[:space:]]+Inlet/, result.speech)
    assert_equal result.speech, result.pieces.join
    assert_operator result.pieces.size, :>, 1
    assert_equal result.pieces.size, result.broadcasts
    assert_equal result.speech, result.tapes.fetch("Port Townsend slip")
    assert_equal result.speech, result.tapes.fetch("tender Alden")
    assert_equal result.tapes.fetch("Port Townsend slip"), result.tapes.fetch("tender Alden")
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/watch_broadcast.yml", __dir__))

    refute_match(/sk-or-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
