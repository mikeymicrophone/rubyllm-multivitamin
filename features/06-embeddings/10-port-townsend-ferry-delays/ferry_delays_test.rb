# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "ferry_delays"

class FerryDelayRankTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/ferry_delays.yml", __dir__)

  def test_the_crosswind_note_is_named_first
    result = nil
    Multivitamin::Cassettes.play(__dir__, "ferry_delays") do
      result = PortTownsendFerryDelays::FerryDelays.conduct
    end

    assert_equal "Crosswind on the Port Townsend slip", result.winner
    titles = result.ranking.map(&:title)
    assert_equal titles, titles.uniq
    assert_equal 3, result.ranking.length
    assert_operator result.ranking.fetch(0).score, :>, result.ranking.fetch(1).score
    assert_equal "text-embedding-3-small", result.model_id
    assert_operator result.input_tokens, :>, 0
    assert_operator result.cost, :>, 0

    request = request_bodies.fetch(0)
    assert_includes request, "holding in the slip"
    assert_includes request, "Crosswind 28 kn"
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
