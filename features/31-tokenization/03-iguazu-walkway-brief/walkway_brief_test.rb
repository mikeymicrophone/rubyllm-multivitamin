# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../support/cassette_assertions"
require_relative "walkway_brief"

class IguazuWalkwayBriefTest < Minitest::Test
  include Multivitamin::CassetteAssertions

  def test_the_request_count_includes_both_posted_notices
    result = play

    assert_instance_of Integer, result.fetch(:count)
    assert_operator result.fetch(:count), :>, 0
    request = requests.fetch(0)
    assert_equal Multivitamin::Models::OPENAI_CHAT, request.fetch("model")
    assert_includes request.dig("input", 0, "content"), "Marta checks the railing at 08:10"
    assert_includes request.dig("input", 0, "content"), "Diego holds group IGU-12"
    assert_includes request.dig("input", 0, "content"), result.fetch(:bulletin)
    assert_equal 1, requests.length
    assert_match(%r{/responses/input_tokens\z}, interactions.fetch(0).dig("request", "uri"))
    refute request.key?("stream")
  end

  def test_cassette_has_no_live_key
    assert_cassette_sanitized(__dir__, "walkway_brief", key: "OPENAI_API_KEY")
  end

  def play
    Multivitamin::Cassettes.play(__dir__, "walkway_brief") { IguazuWalkwayBrief.conduct }
  end

  def requests = cassette_requests(__dir__, "walkway_brief")
  def interactions = cassette_interactions(__dir__, "walkway_brief")
end
