# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "yaml"
require_relative "ratha_count"

class PuriRathaSpokeReportedCostTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/ratha_count.yml", __dir__)

  def test_reported_cost_wins_and_registry_prices_the_same_work
    result = nil
    Multivitamin::Cassettes.play(__dir__, "ratha_count") do
      result = PuriRathaSpoke::RathaCount.conduct
    end

    assert_includes result.brief, "86"
    assert_match(/spoke|ratha/i, result.brief)
    usage_cost = JSON.parse(response_body).dig("usage", "cost")
    assert_equal usage_cost, result.cost_total
    assert_equal usage_cost, result.reported_cost
    assert_equal 0, result.cost_total
    assert_equal 0.0, result.cost_input
    assert_equal 0.0, result.cost_output
    assert_operator result.registry_mini_total, :>, 0
    assert_equal 0, result.unlisted_with_reported
    assert_nil result.bare_unlisted_total
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end

  def response_body
    YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0).dig("response", "body", "string")
  end
end
