# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "sill_surveys"

class SillSurveyRankTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/sill_surveys.yml", __dir__)

  def test_the_sill_paraphrase_outranks_the_crane
    result = nil
    Multivitamin::Cassettes.play(__dir__, "sill_surveys") do
      result = BremertonDryDockSurveys::SillSurveys.conduct
    end

    assert_operator result.paraphrase_score, :>, result.crane_score
    assert_operator result.paraphrase_score, :>, 0.4
    assert_equal "text-embedding-3-small", result.model_id
    assert_operator result.input_tokens, :>, 0
    assert_operator result.cost, :>, 0

    request = request_bodies.fetch(0)
    assert_includes request, "14 ft above the blocks"
    assert_includes request, "snatch block"
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
