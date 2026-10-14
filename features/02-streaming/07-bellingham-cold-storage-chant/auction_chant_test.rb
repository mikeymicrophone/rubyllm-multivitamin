# frozen_string_literal: true

require "minitest/autorun"
require "stringio"
require_relative "auction_chant"

class AuctionChantTest < Minitest::Test
  def test_the_chant_is_written_to_the_tape_and_pulled_from_an_enumerator
    tape = StringIO.new
    result = nil
    Multivitamin::Cassettes.play(__dir__, "auction_chant") do
      BellinghamAuctionChant::AuctionChant.configure
      board = BellinghamAuctionChant::AuctionChant.new
      pending = board.each_bid(tape)
      assert_instance_of Enumerator, pending
      assert_nil board.chant

      pieces = pending.to_a
      result = BellinghamAuctionChant::AuctionChant::Result.new(
        speech: board.chant.content,
        pieces: pieces,
        tape: tape.string,
        bid_count: pieces.size
      )
    end

    assert_operator result.bid_count, :>, 1
    assert_equal result.speech, result.pieces.join
    assert_equal result.speech, result.tape
    assert_equal result.speech, tape.string

    %w[14 15 16 17].each { |lot| assert_includes result.speech, lot }
    assert_includes result.speech, "Alden"
    assert_includes result.speech, "Retort"

    positions = %w[14 15 16 17].map { |lot| result.speech.index(lot) }
    assert_equal positions.sort, positions
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/auction_chant.yml", __dir__))

    refute_match(/sk-or-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
