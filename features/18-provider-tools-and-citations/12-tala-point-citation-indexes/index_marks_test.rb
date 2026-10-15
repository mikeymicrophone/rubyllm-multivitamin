# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "index_marks"

class ProviderToolsTalaPointCitationIndexesTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/index_marks.yml", __dir__)

  def test_the_cited_span_matches_the_indexes_on_the_hail
    result = nil
    Multivitamin::Cassettes.play(__dir__, "index_marks") do
      result = TalaPointCitationIndexes::IndexMarks.conduct
    end

    assert_match(/Tala Point/i, result.brief)
    assert_match(/Alden/i, result.brief)
    assert result.citations.any?
    assert_includes result.call_types, "web_search_call"
    assert_operator result.cost, :>, 0

    result.citations.each_with_index do |citation, index|
      assert citation.url
      assert citation.start_index
      assert citation.end_index
      assert_equal citation.text, result.spans.fetch(index)
      assert_equal citation.text, result.brief[citation.start_index...citation.end_index]
      assert_equal citation.url, result.hashes.fetch(index).fetch(:url)
      refute result.hashes.fetch(index).key?(:cited_text)
      refute result.hashes.fetch(index).key?(:start_page)
    end
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
