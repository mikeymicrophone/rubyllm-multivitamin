# frozen_string_literal: true

require "minitest/autorun"
require_relative "sandalwood_chip"

class PerthSandalwoodChipIoTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/sandalwood_chip.yml", __dir__)

  def test_the_io_keeps_the_filename
    result = nil
    Multivitamin::Cassettes.play(__dir__, "sandalwood_chip") do
      result = PerthSandalwoodChip::SandalwoodChip.conduct
    end

    assert_match(/\Afile-/, result.file_id)
    assert_equal "sandalwood-chip.pdf", result.filename
    assert_equal "user_data", result.purpose
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
