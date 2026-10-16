# frozen_string_literal: true

require "minitest/autorun"
require_relative "rose_attar"

class PlovdivRoseAttarTest < Minitest::Test
  def test_find_returns_the_same_batch_id
    result = nil
    Multivitamin::Cassettes.play(__dir__, "rose_attar") do
      result = PlovdivRoseAttar::AttarBatch.conduct
    end

    assert result.same_id
    assert_equal result.submitted_id, result.found_id
    assert_includes %i[pending succeeded failed cancelled], result.found_status
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/rose_attar.yml", __dir__))

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
