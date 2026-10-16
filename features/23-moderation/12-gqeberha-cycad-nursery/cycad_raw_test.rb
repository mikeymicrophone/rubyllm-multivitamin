# frozen_string_literal: true

require "minitest/autorun"
require_relative "cycad_raw"

class GqeberhaCycadNurseryRawTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/cycad_raw.yml", __dir__)

  def test_the_raw_body_keeps_openai_assessments
    result = nil
    Multivitamin::Cassettes.play(__dir__, "cycad_raw") do
      result = GqeberhaCycadNursery::CycadRaw.conduct
    end

    refute result.flagged
    refute_nil result.raw_id
    assert_kind_of Hash, result.applied_types
    refute_empty result.score_keys
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
