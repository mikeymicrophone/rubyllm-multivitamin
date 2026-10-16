# frozen_string_literal: true

require "minitest/autorun"
require_relative "durian_lot"

class MedanDurianLotCsvTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/durian_lot.yml", __dir__)

  def test_the_csv_stores_and_finds
    result = nil
    Multivitamin::Cassettes.play(__dir__, "durian_lot") do
      result = MedanDurianLot::DurianLot.conduct
    end

    assert_match(/\Afile-/, result.file_id)
    assert_equal result.file_id, result.found_id
    assert_includes result.filename, "durian-lot"
    assert_equal "user_data", result.purpose
    assert_operator result.byte_size, :>, 0
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
