# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../support/cassette_assertions"
require_relative "moai_survey"

class RapaNuiMoaiSurveyTest < Minitest::Test
  include Multivitamin::CassetteAssertions

  def test_the_staged_pdf_is_in_the_count_and_generation_is_still_pending
    result = play

    assert_operator result.fetch(:estimate), :>, 0
    assert_equal %i[system user], result.fetch(:roles)
    refute result.fetch(:complete)
    assert_equal ["ahu-tongariki.pdf"], result.fetch(:attachments)
    content = requests.fetch(0).dig("input", 0, "content")
    attachment = content.find { _1["type"] == "input_file" }
    assert_equal "ahu-tongariki.pdf", attachment.fetch("filename")
    prefix, encoded = attachment.fetch("file_data").split(",", 2)
    assert_equal "data:application/pdf;base64", prefix
    assert_equal File.binread(File.expand_path("fixtures/ahu-tongariki.pdf", __dir__)), Base64.decode64(encoded)
    assert_match(/Hina observes moai RNU-12/, Base64.decode64(encoded))
    assert_equal 1, interactions.length
  end

  def test_cassette_has_no_live_key
    assert_cassette_sanitized(__dir__, "moai_survey", key: "OPENAI_API_KEY")
  end

  def play
    Multivitamin::Cassettes.play(__dir__, "moai_survey") { RapaNuiMoaiSurvey.conduct }
  end

  def requests = cassette_requests(__dir__, "moai_survey")
  def interactions = cassette_interactions(__dir__, "moai_survey")
end
