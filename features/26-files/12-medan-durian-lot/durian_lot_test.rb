# frozen_string_literal: true

require "minitest/autorun"
require_relative "durian_lot"

class MedanDurianLotCsvTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/durian_lot.yml", __dir__)

  def test_the_csv_round_trips
    result = nil
    Multivitamin::Cassettes.play(__dir__, "durian_lot") do
      result = MedanDurianLot::DurianLot.conduct
    end

    assert_match(/\Afile-/, result.file_id)
    assert_includes result.filename, "durian-lot"
    assert_includes result.blob, "MDN-2026-1016-D9"
    assert_includes result.blob, "07:25"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
