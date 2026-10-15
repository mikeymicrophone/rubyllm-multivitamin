# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "hall_holds"

class HallHoldRankTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/hall_holds.yml", __dir__)

  def test_the_soundboard_note_is_named_first
    result = nil
    Multivitamin::Cassettes.play(__dir__, "hall_holds") do
      result = TaipeiNanguanHold::HallHolds.conduct
    end

    assert_equal "Cracked soundboard on the pipa", result.winner
    titles = result.ranking.map(&:title)
    assert_equal titles, titles.uniq
    assert_equal 3, result.ranking.length
    assert_operator result.ranking.fetch(0).score, :>, result.ranking.fetch(1).score
    assert_equal "text-embedding-3-small", result.model_id
    assert_operator result.input_tokens, :>, 0
    assert_operator result.cost, :>, 0

    request = request_bodies.fetch(0)
    assert_includes request, "holding in the hall"
    assert_includes request, "Soundboard split 28"
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
