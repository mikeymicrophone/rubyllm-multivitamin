# frozen_string_literal: true

require "minitest/autorun"
require_relative "salsa_shoe"

class CaliSalsaShoeTest < Minitest::Test
  def test_the_rails_batch_row_stores_the_last_log
    result = nil
    Multivitamin::Cassettes.play(__dir__, "salsa_shoe") do
      result = CaliSalsaShoe::ShoeBatch.conduct
    end

    refute_nil result.row_id
    assert_equal result.batch_id, RubyLLM::ActiveRecord::Batch.find(result.row_id).provider_batch_id
    assert_equal 1, result.chat_ids.size
    assert_equal "openai", result.provider
    assert_includes %w[pending succeeded failed cancelled], result.status
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/salsa_shoe.yml", __dir__))

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
