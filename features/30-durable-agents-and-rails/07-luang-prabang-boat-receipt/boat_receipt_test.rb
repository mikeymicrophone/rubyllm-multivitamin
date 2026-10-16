# frozen_string_literal: true

require "minitest/autorun"
require_relative "boat_receipt"

class LuangPrabangBoatReceiptTest < Minitest::Test
  def test_boat_receipt_survives_a_lost_result
    result = Multivitamin::Cassettes.play(__dir__, "boat_receipt") { LuangPrabangBoatReceipt.conduct }

    assert result.fetch(:lost)
    assert_equal 1, result.fetch(:receipts)
    assert_equal 18, result.fetch(:sacks)
    assert_equal 2, result.fetch(:attempts)
    assert_equal 1, result.fetch(:results)
    assert_includes result.fetch(:brief), "LP-86"
  end

  def test_cassette_has_no_live_key
    cassette = File.binread(File.join(__dir__, "cassettes/boat_receipt.yml"))
    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
