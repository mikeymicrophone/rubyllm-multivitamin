# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "squamish_capstone"

class TranscriptionSquamishHarborCapstoneTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/squamish_capstone.yml", __dir__)

  def test_the_squamish_tape_keeps_times_and_posts_the_card
    result = nil
    Multivitamin::Cassettes.play(__dir__, "squamish_capstone") do
      result = SquamishHarborCapstone::WatchTape.conduct
    end

    assert_equal Multivitamin::Models::OPENAI_TRANSCRIBE_WHISPER, result.tape_model
    assert_match(/Squamish/i, result.tape_text)
    assert_match(/Alden/i, result.tape_text)
    assert_match(/kelp/i, result.tape_text)
    assert_kind_of Array, result.words
    assert_kind_of Array, result.segments
    assert_operator result.words.length, :>, 0
    assert_operator result.segments.length, :>, 0
    assert_operator result.duration, :>, 0
    assert_match(/Alden/i, result.brief)
    assert_match(/10:46|10\.46|1046/, result.brief)
    assert_equal %i[system user assistant], result.roles

    interactions = YAML.load_file(CASSETTE).fetch("http_interactions")
    assert_equal 2, interactions.length
    body = interactions.fetch(0).dig("request", "body", "string")
    assert_includes body, "verbose_json"
    assert_includes body, "Squamish Harbor"
    assert_includes body, "kelp ledge"
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
