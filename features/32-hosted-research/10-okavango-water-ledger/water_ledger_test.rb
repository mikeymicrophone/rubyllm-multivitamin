# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../support/research_assertions"
require_relative "water_ledger"

class OkavangoWaterLedgerTest < Minitest::Test
  include Multivitamin::ResearchAssertions

  CASSETTE = File.expand_path("cassettes/water_ledger.yml", __dir__)

  def test_water_ledger_research_flow
    ledger = Multivitamin::Cassettes.play(__dir__, "water_ledger") { OkavangoWaterLedger.conduct }
    assert_includes ledger.fetch(:report), "Okavango"
    assert_nil ledger.fetch(:cost)
    assert_nil ledger.fetch(:message_cost)
    assert_equal({ input: 1150, output: 360, thinking: 100 }, ledger.fetch(:buckets))
    assert_equal 1510, ledger.fetch(:billed_tokens)
    assert_equal Multivitamin::Models::VERTEXAI_RESEARCH, ledger.fetch(:agent)
  end

  def test_cassette_does_not_carry_a_live_key
    assert_research_credentials_filtered
  end
end
