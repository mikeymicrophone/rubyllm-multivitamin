# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../support/research_assertions"
require_relative "mosaic_watch"

class SamarkandMosaicWatchTest < Minitest::Test
  include Multivitamin::ResearchAssertions

  CASSETTE = File.expand_path("cassettes/mosaic_watch.yml", __dir__)

  def test_mosaic_watch_research_flow
    watch = Multivitamin::Cassettes.play(__dir__, "mosaic_watch") { SamarkandMosaicWatch::MosaicWatch.new.conduct }
    assert_nil watch.pending_report
    assert_equal %i[pending pending completed], watch.states
    assert watch.job.completed?
    assert_same watch.job, watch.job.refresh
    assert_includes watch.report, "Registan"
    assert_includes watch.report, "salt"
    refute requests.first.key?("tools")
    assert_equal %w[post get get], interactions.map { |turn| turn.dig("request", "method") }
  end

  def test_cassette_does_not_carry_a_live_key
    assert_research_credentials_filtered
  end
end
