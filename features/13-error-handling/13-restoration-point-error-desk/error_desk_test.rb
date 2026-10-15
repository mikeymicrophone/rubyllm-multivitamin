# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "yaml"
require_relative "error_desk"

class RestorationPointErrorDeskTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/error_desk.yml", __dir__)

  def test_the_desk_logs_the_shape_and_still_briefs_alden
    result = nil
    Multivitamin::Cassettes.play(__dir__, "error_desk") do
      result = RestorationPointErrorDesk::ErrorDesk.conduct
    end

    assert_instance_of RubyLLM::BadRequestError, result.error
    assert_equal 400, result.status
    assert_includes result.error.message, "SlipBerth"
    assert_includes result.error.message, "power"
    assert_equal %i[
      provider model step payload_keys thinking_settings instructions
      turn_count omitted_turns turns tool_names tool_rounds problems
    ], result.shape_hash.keys
    refute_includes result.shape_text, "G-4"
    refute_includes result.shape_text, "Alden"
    refute_includes JSON.generate(result.shape_hash), "G-4"
    assert_includes result.brief, "Alden"
    assert_includes result.brief, "G-4"
    assert_equal %i[system user assistant], result.roles

    statuses = interactions.map { |hit| hit.dig("response", "status", "code") }
    assert_equal [400, 200], statuses
    refute_includes interactions.fetch(1).dig("request", "body", "string"), "json_schema"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def interactions
    YAML.load_file(CASSETTE).fetch("http_interactions")
  end
end
