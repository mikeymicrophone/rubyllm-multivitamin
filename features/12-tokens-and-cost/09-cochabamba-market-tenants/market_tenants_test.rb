# frozen_string_literal: true

require "minitest/autorun"
require_relative "market_tenants"

class CochabambaMarketTenantTalliesTest < Minitest::Test
  def test_two_tenants_keep_separate_tallies_and_aggregate_sums_them
    result = nil
    Multivitamin::Cassettes.play(__dir__, "market_tenants") do
      result = CochabambaMarketTenants::MarketTenants.conduct
    end

    assert_includes result.mill_brief, "42"
    assert_includes result.mill_brief, "LC-4"
    assert_includes result.oven_brief, "28"
    assert_match(/07:30|7:30/, result.oven_brief)

    assert_equal [CochabambaMarketTenants::MarketTenants::MILL], result.mill_owner
    assert_equal [CochabambaMarketTenants::MarketTenants::OVEN], result.oven_owner
    refute_equal result.mill_owner, result.oven_owner

    assert_equal 0, result.mill_cost
    assert_equal 0, result.oven_cost
    assert_equal 0, result.aggregated_cost
    assert_operator result.mill_input, :>, 0
    assert_operator result.oven_input, :>, 0
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/market_tenants.yml", __dir__))

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
