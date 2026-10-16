# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../support/cassette_assertions"
require_relative "cistern_survey"

class PetraCisternSurveySurveyDeskTest < Minitest::Test
  include Multivitamin::CassetteAssertions

  def test_counting_a_follow_up_keeps_the_seeded_history_unchanged
    result = play

    assert_operator result.fetch(:estimate), :>, 0
    assert_equal %i[system user assistant], result.fetch(:before).map(&:role)
    assert_equal result.fetch(:before).map(&:object_id), result.fetch(:after).map(&:object_id)
    request = requests.fetch(0)
    assert_match(/Siq survey/, request.fetch("instructions"))
    assert_equal %w[user assistant user], request.fetch("input").map { _1.fetch("role") }
    assert_equal result.fetch(:question), request.fetch("input").last.fetch("content")
    assert_match(/62 cm/, request.dig("input", 1, "content", 0, "text"))
  end

  def test_cassette_has_no_live_key
    assert_cassette_sanitized(__dir__, "cistern_survey", key: "OPENAI_API_KEY")
  end

  def play
    Multivitamin::Cassettes.play(__dir__, "cistern_survey") { PetraCisternSurvey::SurveyDesk.conduct }
  end

  def requests = cassette_requests(__dir__, "cistern_survey")
  def interactions = cassette_interactions(__dir__, "cistern_survey")
end
