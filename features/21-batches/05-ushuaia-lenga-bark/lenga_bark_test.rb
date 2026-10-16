# frozen_string_literal: true

require "minitest/autorun"
require_relative "lenga_bark"

class UshuaiaLengaBarkTest < Minitest::Test
  def test_embed_later_submits_an_embedding_batch
    result = nil
    Multivitamin::Cassettes.play(__dir__, "lenga_bark") do
      result = UshuaiaLengaBark::BarkBatch.conduct
    end

    refute_nil result.batch_id
    assert_equal 2, result.request_count
    assert_equal 2, result.results.size
    assert_equal [nil, nil], result.results unless result.complete
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/lenga_bark.yml", __dir__))

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
