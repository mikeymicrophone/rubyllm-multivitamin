# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "salt_ledger"

class TimbuktuSaltLedgerTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/salt_ledger.yml", __dir__)

  def test_the_uploaded_ledger_briefs_aisha
    result = nil
    Multivitamin::Cassettes.play(__dir__, "salt_ledger") do
      result = TimbuktuSaltLedger::SaltLedger.conduct
    end

    assert_match(/\Afile-/, result.file_id)
    assert_equal "user_data", result.purpose
    assert_includes result.filename, "salt-ledger"
    assert_includes result.brief, "Aisha"
    assert_includes result.brief, "TMB-2026-1016-S3"
    assert_equal 2, interactions.length
    assert_includes interactions.fetch(0).dig("request", "uri"), "/files"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def interactions
    YAML.load_file(CASSETTE).fetch("http_interactions")
  end
end
