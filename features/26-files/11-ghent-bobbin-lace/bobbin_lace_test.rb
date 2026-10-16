# frozen_string_literal: true

require "minitest/autorun"
require_relative "bobbin_lace"

class GhentBobbinLaceDownloadTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/bobbin_lace.yml", __dir__)

  def test_the_batch_download_keeps_the_pillow_code
    result = nil
    Multivitamin::Cassettes.play(__dir__, "bobbin_lace") do
      result = GhentBobbinLace::BobbinLace.conduct
    end

    assert_match(/\Afile-/, result.file_id)
    assert_equal "batch", result.purpose
    assert_includes result.blob, "GNT-2026-1016-L6"
    assert_operator result.byte_size, :>, 0
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
