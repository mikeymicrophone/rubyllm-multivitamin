# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "yaml"
require_relative "deny_charge"

class DenyChargeTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/deny_charge.yml", __dir__)

  def test_the_range_officer_denies_the_charge
    result = nil
    Multivitamin::Cassettes.play(__dir__, "deny_charge") do
      result = DabobBayDenyCharge::RangeOfficer.conduct
    end

    assert result.awaiting
    refute result.fired
    denial = JSON.parse(result.denial)
    assert_equal "The user denied the fire_range_charge tool call.", denial.fetch("error")
    refute_includes result.denial, "2 lb"
    assert_includes result.answer, "DB-7"
    refute_match(/fired a 2 lb/i, result.answer)
    assert_equal %i[system user assistant tool assistant], result.roles
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
