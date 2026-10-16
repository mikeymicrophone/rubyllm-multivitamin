# frozen_string_literal: true

require "minitest/autorun"
require_relative "bark_empty"

class KampalaBarkClothEmptyTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/bark_empty.yml", __dir__)

  def test_an_empty_panel_list_does_not_rank
    result = nil
    Multivitamin::Cassettes.play(__dir__, "bark_empty") do
      result = KampalaBarkCloth::BarkEmpty.conduct
    end

    if result.error
      assert_kind_of Exception, result.error
      refute_match(/sk-/, result.error.message)
    else
      assert_equal 0, result.count
    end
  end

  def test_cassette_key_when_recorded
    return unless File.exist?(CASSETTE)

    cassette = File.binread(CASSETTE)
    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
