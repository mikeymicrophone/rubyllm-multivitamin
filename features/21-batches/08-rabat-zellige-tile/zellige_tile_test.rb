# frozen_string_literal: true

require "minitest/autorun"
require_relative "zellige_tile"

class RabatZelligeTileTest < Minitest::Test
  def test_cancel_marks_the_batch_cancelling
    result = nil
    Multivitamin::Cassettes.play(__dir__, "zellige_tile") do
      result = RabatZelligeTile::TileBatch.conduct
    end

    assert_match(/cancel/i, result.raw_status.to_s)
    refute result.succeeded
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/zellige_tile.yml", __dir__))

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
