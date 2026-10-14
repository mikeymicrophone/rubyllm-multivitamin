# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "chart_blurbs"

class ChartBlurbDedupTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/chart_blurbs.yml", __dir__)

  def test_the_move_blurbs_cluster_and_the_cook_card_ranks_lower
    result = nil
    Multivitamin::Cassettes.play(__dir__, "chart_blurbs") do
      result = JuanDeFucaChartBlurbs::ChartBlurbs.conduct
    end

    assert_includes result.duplicate_titles, "DH moved northwest"
    assert_includes result.duplicate_titles, "DH shifted 300 yards"
    refute_includes result.duplicate_titles, "Cook card DH-18465"
    assert_equal ["Cook card DH-18465"], result.cook_cluster
    assert_equal 2, result.clusters.length
    refute_equal "Cook card DH-18465", result.winner
    assert_operator result.cook_score, :<, 0.6
    assert_equal "text-embedding-3-small", result.model_id
    assert_operator result.input_tokens, :>, 0
    assert_operator result.cost, :>, 0

    request = request_bodies.fetch(0)
    assert_includes request, "300 yards northwest"
    assert_includes request, "pink-salmon cook"
    assert_includes request, "Where did lighted bell buoy DH move"
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
