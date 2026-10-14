# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "watch_logs"

class WatchLogSearchTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/watch_logs.yml", __dir__)

  def test_the_kelp_ledge_question_ranks_the_tide_board_first
    result = nil
    Multivitamin::Cassettes.play(__dir__, "watch_logs") do
      result = AdmiraltyInletWatchLogs::WatchLogs.conduct
    end

    assert_equal "Point Wilson tide board", result.winner
    titles = result.ranking.map(&:title)
    assert_equal 4, titles.length
    assert_includes titles, "Cape Disappointment horn card"
    assert_includes titles, "Anacortes morning cook"
    assert_includes titles, "Friday Harbor slip B4"
    assert_operator result.ranking.fetch(0).score, :>, result.ranking.fetch(1).score
    assert_equal "text-embedding-3-small", result.model_id
    assert_operator result.input_tokens, :>, 0
    assert_operator result.cost, :>, 0
    assert_equal %i[query corpus], result.roles

    request = request_bodies.fetch(0)
    assert_includes request, "kelp ledge"
    assert_includes request, "10:46"
    assert_equal 1, YAML.load_file(CASSETTE).fetch("http_interactions").length
  end

  def test_a_second_play_ranks_the_same_titles
    return if ENV["LIVE"] == "1"

    first = nil
    Multivitamin::Cassettes.play(__dir__, "watch_logs") do
      first = AdmiraltyInletWatchLogs::WatchLogs.conduct
    end
    second = nil
    Multivitamin::Cassettes.play(__dir__, "watch_logs") do
      second = AdmiraltyInletWatchLogs::WatchLogs.conduct
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
