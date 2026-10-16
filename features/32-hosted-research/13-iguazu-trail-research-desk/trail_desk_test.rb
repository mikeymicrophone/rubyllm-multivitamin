# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../support/research_assertions"
require_relative "trail_desk"

class IguazuTrailResearchDeskTest < Minitest::Test
  include Multivitamin::ResearchAssertions

  CASSETTE = File.expand_path("cassettes/trail_desk.yml", __dir__)

  def test_trail_desk_research_flow
    handover = Multivitamin::Cassettes.play(__dir__, "trail_desk") { IguazuTrailResearchDesk::TrailDesk.new.conduct }
    assert_equal %i[argentina brazil], handover.reports.keys
    assert_includes handover.reports.fetch(:argentina).content, "Iguazú"
    assert_includes handover.reports.fetch(:brazil).content, "Iguaçu"
    assert handover.reports.values.all? { |report| IguazuTrailResearchDesk::TrailDesk.search_performed?(report) }
    assert_equal 2, handover.jobs.uniq.length
    assert_operator handover.tokens, :>, 0
    assert_equal 2, handover.sources.length
    assert_equal %w[post post get get], interactions.map { |turn| turn.dig("request", "method") }
  end

  def test_cassette_does_not_carry_a_live_key
    assert_research_credentials_filtered
  end

  def test_failed_study_retains_both_ids_and_restores_replay_headers
    desk = IguazuTrailResearchDesk::TrailDesk.new
    original_headers = RubyLLM::Providers::VertexAI.instance_method(:headers)
    failure = assert_raises(RuntimeError) do
      Multivitamin::Cassettes.play(__dir__, "trail_failed") { desk.conduct }
    end
    assert_equal %i[failed pending], desk.jobs.map(&:status)
    desk.jobs.each { |job| assert_includes failure.message, job.id }
    assert_match(/source retrieval failed/, failure.message)
    assert_equal original_headers, RubyLLM::Providers::VertexAI.instance_method(:headers)
  end
end
