# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "tally_cards"

class TallyEmptyCardTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/tally_cards.yml", __dir__)

  def test_a_blank_card_embeds_and_an_empty_stack_is_a_400
    result = nil
    Multivitamin::Cassettes.play(__dir__, "tally_cards") do
      result = BishkekTallyCards::TallyCards.conduct
    end

    assert_equal 1536, result.blank_length
    assert_equal 0, result.blank_tokens
    assert_equal 0, result.blank_cost
    refute result.blank_all_zero
    assert_equal "RubyLLM::BadRequestError", result.stack_error
    assert_match(/empty array/i, result.stack_message)

    interactions = YAML.load_file(CASSETTE).fetch("http_interactions")
    assert_equal 2, interactions.length
    assert_includes interactions.fetch(0).dig("request", "body", "string"), '"input":""'
    assert_equal 200, interactions.fetch(0).dig("response", "status", "code")
    assert_includes interactions.fetch(1).dig("request", "body", "string"), '"input":[]'
    assert_equal 400, interactions.fetch(1).dig("response", "status", "code")
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
