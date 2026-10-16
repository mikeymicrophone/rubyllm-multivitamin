# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../support/cassette_assertions"
require_relative "bridge_inspection"

class IsfahanBridgeInspectionTest < Minitest::Test
  include Multivitamin::CassetteAssertions

  def test_hosted_tools_options_and_request_hooks_are_excluded_from_the_count
    result = play
    baseline, decorated = requests

    assert_operator result.fetch(:baseline), :>, 0
    assert_equal result.fetch(:baseline), result.fetch(:decorated)
    assert_empty result.fetch(:hook_calls)
    assert_equal [:system], result.fetch(:roles)
    assert_equal baseline, decorated
    refute decorated.key?("tools")
    refute decorated.key?("metadata")
    assert_includes decorated.dig("input", 0, "content"), "ISF-11"
  end

  def test_cassette_has_no_live_key
    assert_cassette_sanitized(__dir__, "bridge_inspection", key: "OPENAI_API_KEY")
  end

  def play
    Multivitamin::Cassettes.play(__dir__, "bridge_inspection") { IsfahanBridgeInspection.conduct }
  end

  def requests = cassette_requests(__dir__, "bridge_inspection")
  def interactions = cassette_interactions(__dir__, "bridge_inspection")
end
