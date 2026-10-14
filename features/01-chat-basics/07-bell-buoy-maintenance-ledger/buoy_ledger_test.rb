# frozen_string_literal: true

require "minitest/autorun"
require_relative "buoy_ledger"

class BuoyLedgerTest < Minitest::Test
  def test_say_builds_a_transcript_the_tender_can_read_back
    result = nil
    Multivitamin::Cassettes.play(__dir__, "buoy_ledger") do
      result = EdizHookBellBuoy::BuoyLedger.conduct
    end

    assert_equal RubyLLM::Chat.instance_method(:ask), RubyLLM::Chat.instance_method(:say)

    assert_includes result.clapper, "2 April 2026"
    assert_includes result.clapper, "11.8"
    assert_includes result.haul, "3 November 2026"
    assert_includes result.haul, "11.8"

    assert_equal %i[system user assistant user assistant], result.roles
    assert_equal result.roles, result.transcript.map(&:first)
    assert_includes result.transcript[1].last, "Ediz Hook"
    assert_includes result.transcript[3].last, "next haul"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/buoy_ledger.yml", __dir__))

    refute_match(/sk-or-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
