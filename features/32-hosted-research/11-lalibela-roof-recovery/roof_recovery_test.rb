# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../support/research_assertions"
require_relative "roof_recovery"

class LalibelaRoofRecoveryTest < Minitest::Test
  include Multivitamin::ResearchAssertions

  CASSETTE = File.expand_path("cassettes/roof_recovery.yml", __dir__)

  def test_roof_recovery_research_flow
    recovered = Multivitamin::Cassettes.play(__dir__, "roof_recovery") { LalibelaRoofRecovery.conduct }
    assert_equal "research-lalibela-roofs-11", recovered.fetch(:id)
    assert_equal :completed, recovered.fetch(:status)
    assert_includes recovered.fetch(:report), "Lalibela"
    refute_empty recovered.fetch(:sources)
    assert interactions.all? { |turn| turn.dig("request", "method") == "get" }
    assert_equal 2, interactions.length
  end

  def test_cassette_does_not_carry_a_live_key
    assert_research_credentials_filtered
  end
end
