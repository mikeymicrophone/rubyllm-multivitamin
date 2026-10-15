# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "ward_logs"

class WardLogSearchTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/ward_logs.yml", __dir__)

  def test_the_paediatric_question_ranks_the_vitals_board_first
    result = nil
    Multivitamin::Cassettes.play(__dir__, "ward_logs") do
      result = LusakaWardHandover::WardLogs.conduct
    end

    assert_equal "Paediatric vitals board", result.winner
    titles = result.ranking.map(&:title)
    assert_equal 4, titles.length
    assert_includes titles, "Main autoclave card"
    assert_includes titles, "Kitchen nshima pot"
    assert_includes titles, "Pharmacy window B4"
    assert_operator result.ranking.fetch(0).score, :>, result.ranking.fetch(1).score
    assert_equal "text-embedding-3-small", result.model_id
    assert_operator result.input_tokens, :>, 0
    assert_operator result.cost, :>, 0
    assert_equal %i[query corpus], result.roles

    request = request_bodies.fetch(0)
    assert_includes request, "paediatric bay"
    assert_includes request, "10:46"
    assert_equal 1, YAML.load_file(CASSETTE).fetch("http_interactions").length
  end

  def test_a_second_play_ranks_the_same_titles
    return if ENV["LIVE"] == "1"

    first = nil
    Multivitamin::Cassettes.play(__dir__, "ward_logs") do
      first = LusakaWardHandover::WardLogs.conduct
    end
    second = nil
    Multivitamin::Cassettes.play(__dir__, "ward_logs") do
      second = LusakaWardHandover::WardLogs.conduct
    end

    assert_equal first.winner, second.winner
    assert_equal first.ranking.map(&:title), second.ranking.map(&:title)
    assert_equal first.ranking.map(&:score), second.ranking.map(&:score)
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
    refute_includes cassette, "Bearer sk-"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map do |interaction|
      interaction.dig("request", "body", "string").to_s
    end
  end
end
