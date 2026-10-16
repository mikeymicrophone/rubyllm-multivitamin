# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../support/research_assertions"
require_relative "sandstone_survey"

class PetraSandstoneSurveyTest < Minitest::Test
  include Multivitamin::ResearchAssertions

  CASSETTE = File.expand_path("cassettes/sandstone_survey.yml", __dir__)

  def test_sandstone_survey_research_flow
    survey = Multivitamin::Cassettes.play(__dir__, "sandstone_survey") { PetraSandstoneSurvey.conduct }
    assert_includes survey.report, "Siq"
    assert_includes survey.report, "salt"
    assert_equal [1], survey.pages
    assert_equal ["survey page 1"], survey.page_labels
    attachment = requests.first.fetch("input").last
    assert_equal "document", attachment.fetch("type")
    assert_equal "application/pdf", attachment.fetch("mime_type")
    assert_equal File.binread(PetraSandstoneSurvey::SURVEY), Base64.decode64(attachment.fetch("data"))
    assert_empty requests.first.fetch("tools")
  end

  def test_cassette_does_not_carry_a_live_key
    assert_research_credentials_filtered
  end
end
