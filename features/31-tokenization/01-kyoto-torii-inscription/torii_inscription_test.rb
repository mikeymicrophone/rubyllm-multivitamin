# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../support/cassette_assertions"
require_relative "torii_inscription"

class KyotoToriiInscriptionTest < Minitest::Test
  include Multivitamin::CassetteAssertions

  def test_the_inscription_has_ordered_frozen_ids_and_a_label_allowance
    inscription = play
    tokens = inscription.tokenization

    assert_instance_of RubyLLM::Tokenization, tokens
    assert_equal Multivitamin::Models::COHERE_TOKENIZER, tokens.model
    assert_equal tokens.raw.fetch("tokens"), tokens.ids
    assert_equal tokens.ids.length, tokens.count
    assert_equal inscription.text, tokens.raw.fetch("token_strings").join
    assert tokens.ids.all? { _1.is_a?(Integer) }
    assert tokens.ids.frozen?
    assert inscription.frozen?
    assert_equal inscription.allowance - tokens.count, inscription.remaining
    assert_equal tokens.count <= inscription.allowance, inscription.fits?
    request = requests.fetch(0)
    assert_equal inscription.text, request.fetch("text")
    assert_equal %w[model text], request.keys.sort
  end

  def test_cassette_has_no_live_key
    assert_cassette_sanitized(__dir__, "torii_inscription", key: "COHERE_API_KEY")
  end

  def play
    Multivitamin::Cassettes.play(__dir__, "torii_inscription") { KyotoToriiInscription.conduct }
  end

  def requests = cassette_requests(__dir__, "torii_inscription")
  def interactions = cassette_interactions(__dir__, "torii_inscription")
end
