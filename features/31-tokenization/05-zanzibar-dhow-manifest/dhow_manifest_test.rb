# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../support/cassette_assertions"
require_relative "dhow_manifest"

class ZanzibarDhowManifestTest < Minitest::Test
  include Multivitamin::CassetteAssertions

  def test_the_anthropic_count_includes_both_tool_schemas_without_reading_the_hold
    result = play
    request = requests.fetch(0)
    tools = request.fetch("tools").to_h { |tool| [tool.fetch("name"), tool] }

    assert_operator result.fetch(:estimate), :>, 0
    assert_empty result.fetch(:reads)
    assert_equal [:system], result.fetch(:roles)
    assert_equal %i[berth_ledger cargo_hold], result.fetch(:manifest).keys
    assert_equal ["vessel"], tools.fetch("berth_ledger").dig("input_schema", "required")
    assert_equal ["hold"], tools.fetch("cargo_hold").dig("input_schema", "required")
    assert_equal "any", request.dig("tool_choice", "type")
    assert_includes request.dig("system", 0, "text"), "Asha"
    assert_match(%r{/messages/count_tokens\z}, interactions.fetch(0).dig("request", "uri"))
    refute request.key?("max_tokens")
  end

  def test_cassette_has_no_live_key
    assert_cassette_sanitized(__dir__, "dhow_manifest", key: "ANTHROPIC_API_KEY")
  end

  def play
    Multivitamin::Cassettes.play(__dir__, "dhow_manifest") { ZanzibarDhowManifest.conduct }
  end

  def requests = cassette_requests(__dir__, "dhow_manifest")
  def interactions = cassette_interactions(__dir__, "dhow_manifest")
end
