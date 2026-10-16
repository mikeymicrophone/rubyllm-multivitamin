# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../support/cassette_assertions"
require_relative "registan_label"

class SamarkandRegistanLabelTest < Minitest::Test
  include Multivitamin::CassetteAssertions

  def test_ids_preserve_the_three_repeated_tile_fragments
    result = play
    tokens = result.fetch(:tokenization)
    ordered = result.fetch(:ordered)

    assert_equal tokens.ids, ordered.map(&:first)
    assert_equal 3, result.fetch(:repeated).length
    assert_equal 1, result.fetch(:repeated).uniq.length
    assert_equal tokens.count, ordered.length
    assert_equal requests.fetch(0).fetch("text"), ordered.map(&:last).join
    assert_match(/Registan.*Dilshod/, ordered.map(&:last).join)
    assert_equal Multivitamin::Models::XAI_TOKENIZER, tokens.model
  end

  def test_cassette_has_no_live_key
    assert_cassette_sanitized(__dir__, "registan_label", key: "XAI_API_KEY")
  end

  def play
    Multivitamin::Cassettes.play(__dir__, "registan_label") { SamarkandRegistanLabel.conduct }
  end

  def requests = cassette_requests(__dir__, "registan_label")
  def interactions = cassette_interactions(__dir__, "registan_label")
end
