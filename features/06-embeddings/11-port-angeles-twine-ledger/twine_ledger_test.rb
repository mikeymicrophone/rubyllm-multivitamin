# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "twine_ledger"

class TwineLedgerStoreTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/twine_ledger.yml", __dir__)

  def test_the_ledger_reloads_and_refuses_a_foreign_model
    result = nil
    Multivitamin::Cassettes.play(__dir__, "twine_ledger") do
      result = PortAngelesTwineLedger::TwineLedger.conduct
    end

    assert_equal "Leadline splice on the beach seine", result.winner
    assert result.reloaded
    assert_equal "text-embedding-3-small", result.stored_model
    assert_equal 1536, result.stored_width
    assert_match(/do not mix text-embedding-3-large with a ledger stored as text-embedding-3-small/, result.foreign_error)
    assert_operator result.ranking.fetch(0).score, :>, result.ranking.fetch(1).score
    assert_operator result.query_tokens, :>, 0
    assert_operator result.cost, :>, 0

    interactions = YAML.load_file(CASSETTE).fetch("http_interactions")
    assert_equal 2, interactions.length
    assert_includes request_bodies.fetch(0), "purse seine 17"
    assert_includes request_bodies.fetch(1), "leadline splice"
    refute_includes request_bodies.fetch(1), "text-embedding-3-large"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map do |interaction|
      interaction.dig("request", "body", "string").to_s
    end
  end
end
