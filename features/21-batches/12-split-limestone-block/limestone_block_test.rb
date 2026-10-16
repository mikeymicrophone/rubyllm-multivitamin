# frozen_string_literal: true

require "minitest/autorun"
require_relative "limestone_block"

class SplitLimestoneBlockTest < Minitest::Test
  def test_workshop_headers_stay_off_the_batch_payload
    result = nil
    Multivitamin::Cassettes.play(__dir__, "limestone_block") do
      result = SplitLimestoneBlock::BlockBatch.conduct
    end

    assert_equal "dawn-cut", result.headers.fetch("X-Workshop-Shift")
    refute_includes result.payload_keys, "headers"
    refute_includes result.payload_keys, "X-Workshop-Shift"
    cassette = File.read(File.expand_path("cassettes/limestone_block.yml", __dir__))
    refute_includes cassette, "X-Workshop-Shift"
    refute_includes cassette, "dawn-cut"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/limestone_block.yml", __dir__))

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
