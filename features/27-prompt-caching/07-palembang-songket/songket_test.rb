# frozen_string_literal: true

require "minitest/autorun"
require_relative "songket"

class PalembangSongketSecondAskTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/songket.yml", __dir__)

  def test_the_second_ask_reports_cache_buckets
    result = nil
    Multivitamin::Cassettes.play(__dir__, "songket") do
      result = PalembangSongket::Songket.conduct
    end

    assert_includes result.opening, "Wati"
    assert_includes result.opening, "11:30"
    assert_match(/\ANo\b/, result.follow_up)
    assert_equal %i[system user assistant user assistant], result.roles
    assert_kind_of Integer, result.cache_read
    assert_operator result.cache_read, :>=, 0
    assert_operator result.input_tokens, :>, 0
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
