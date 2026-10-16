# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../support/research_assertions"
require_relative "landing_deadline"

class SundarbansLandingDeadlineTest < Minitest::Test
  include Multivitamin::ResearchAssertions

  CASSETTE = File.expand_path("cassettes/landing_deadline.yml", __dir__)

  def test_landing_deadline_research_flow
    Multivitamin::Cassettes.play(__dir__, "landing_deadline") do
      desk = SundarbansLandingDeadline::LandingDesk.new
      job = desk.submit
      ticks = [100.0, 102.0]
      collection = job.stub(:monotonic_time, -> { ticks.shift || 102.0 }) { desk.collect(timeout: 1, interval: 0.1) }
      assert collection.timed_out
      assert_nil collection.report
      assert_same job, collection.job
      assert job.pending?
      assert_includes desk.recover, "Sundarbans"
      assert job.completed?
    end
    refute interactions.any? { |turn| turn.dig("request", "uri").end_with?("/cancel") }
  end

  def test_cassette_does_not_carry_a_live_key
    assert_research_credentials_filtered
  end
end
