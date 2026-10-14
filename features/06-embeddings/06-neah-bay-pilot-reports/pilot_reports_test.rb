# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "pilot_reports"

class PilotReportTwinTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/pilot_reports.yml", __dir__)

  def test_the_copied_boarding_note_matches_itself
    result = nil
    Multivitamin::Cassettes.play(__dir__, "pilot_reports") do
      result = NeahBayPilotReports::PilotReports.conduct
    end

    assert_in_delta 1.0, result.self_score, 0.0001
    assert_operator result.self_score, :>, result.current_score
    assert_operator result.current_score, :<, 0.7
    assert_equal "text-embedding-3-small", result.model_id
    assert_operator result.input_tokens, :>, 0
    assert_operator result.cost, :>, 0

    request = request_bodies.fetch(0)
    assert_equal 2, request.scan("Salish Grain").length
    assert_includes request, "Ebb 2.4 kn"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map do |interaction|
      interaction.dig("request", "body", "string").to_s
    end
  end
end
