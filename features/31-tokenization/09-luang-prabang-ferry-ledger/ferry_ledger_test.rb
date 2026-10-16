# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../support/cassette_assertions"
require_relative "ferry_ledger"

class LuangPrabangFerryLedgerTest < Minitest::Test
  include Multivitamin::CassetteAssertions

  def test_the_estimate_is_separate_from_reported_usage_and_message_callbacks
    ledger = play

    assert_operator ledger.estimate, :>, 0
    assert_operator ledger.input, :>, 0
    assert_operator ledger.output, :>, 0
    assert_equal ledger.input + ledger.output, ledger.total
    assert_empty ledger.before_callbacks
    assert_equal [:assistant], ledger.callbacks
    assert_equal %i[system user assistant], ledger.roles
    assert_match(/Kham.*LPB-6.*10:25/, ledger.brief)
    count, generation = requests
    assert_equal count.fetch("input"), generation.fetch("input")
    assert_equal count.fetch("instructions"), generation.fetch("instructions")
    assert_match(%r{/input_tokens\z}, interactions.fetch(0).dig("request", "uri"))
    assert_match(%r{/responses\z}, interactions.fetch(1).dig("request", "uri"))
    # No equality between estimate and billed input is promised by this API.
  end

  def test_cassette_has_no_live_key
    assert_cassette_sanitized(__dir__, "ferry_ledger", key: "OPENAI_API_KEY")
  end

  def play
    Multivitamin::Cassettes.play(__dir__, "ferry_ledger") { LuangPrabangFerryLedger.conduct }
  end

  def requests = cassette_requests(__dir__, "ferry_ledger")
  def interactions = cassette_interactions(__dir__, "ferry_ledger")
end
