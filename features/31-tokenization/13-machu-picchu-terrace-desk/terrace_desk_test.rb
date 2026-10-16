# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../support/cassette_assertions"
require_relative "terrace_desk"

class MachuPicchuTerraceDeskTerraceDeskTest < Minitest::Test
  include Multivitamin::CassetteAssertions

  def test_the_growing_conversation_stops_before_staging_the_over_budget_dispatch
    result = play
    admissions = result.fetch(:admissions)

    assert_equal %w[Quispe Huamán Sisa], admissions.map(&:crew)
    assert_equal [true, true, false], admissions.map(&:accepted)
    admissions.first(2).each { assert_operator _1.estimate, :<=, result.fetch(:input_ceiling) }
    assert_operator admissions.last.estimate, :>, result.fetch(:input_ceiling)
    assert_equal %i[system user assistant user assistant], result.fetch(:roles)
    assert_equal 2, result.fetch(:usage_entries)
    assert_match(/Quispe.*MP-4.*08:20/, result.fetch(:briefs).fetch(0))
    assert_match(/Huamán.*MP-7/, result.fetch(:briefs).fetch(1))
    counts = interactions.select { _1.dig("request", "uri").end_with?("/input_tokens") }
    generations = interactions.reject { _1.dig("request", "uri").end_with?("/input_tokens") }
    assert_equal 3, counts.length
    assert_equal 2, generations.length
    assert_equal [1, 3, 5], counts.map { JSON.parse(_1.dig("request", "body", "string")).fetch("input").length }
    generations.each do |interaction|
      request = JSON.parse(interaction.dig("request", "body", "string"))
      assert_equal MachuPicchuTerraceDesk::TerraceDesk::OUTPUT_RESERVE, request.fetch("max_output_tokens")
      refute_includes interaction.dig("request", "body", "string"), "Sisa"
    end
  end

  def test_cassette_has_no_live_key
    assert_cassette_sanitized(__dir__, "terrace_desk", key: "OPENAI_API_KEY")
  end

  def play
    Multivitamin::Cassettes.play(__dir__, "terrace_desk") { MachuPicchuTerraceDesk::TerraceDesk.conduct }
  end

  def requests = cassette_requests(__dir__, "terrace_desk")
  def interactions = cassette_interactions(__dir__, "terrace_desk")
end
