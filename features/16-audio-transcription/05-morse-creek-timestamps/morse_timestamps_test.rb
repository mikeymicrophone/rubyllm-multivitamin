# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "morse_timestamps"

class TranscriptionMorseCreekTimestampsTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/morse_timestamps.yml", __dir__)

  def test_whisper_returns_word_and_segment_times_for_the_sounding
    result = nil
    Multivitamin::Cassettes.play(__dir__, "morse_timestamps") do
      result = MorseCreekTimestamps::CreekSounding.conduct
    end

    assert_equal Multivitamin::Models::OPENAI_TRANSCRIBE_WHISPER, result.model
    assert_match(/Morse/i, result.text)
    assert_match(/fathom/i, result.text)
    assert_kind_of Array, result.words
    assert_kind_of Array, result.segments
    assert_operator result.words.length, :>, 0
    assert_operator result.segments.length, :>, 0
    assert_operator result.duration, :>, 0

    first_word = result.words.fetch(0)
    assert first_word.key?("word") || first_word.key?(:word)
    word = first_word["word"] || first_word[:word]
    start = first_word["start"] || first_word[:start]
    finish = first_word["end"] || first_word[:end]
    assert_kind_of Numeric, start
    assert_kind_of Numeric, finish
    assert_operator finish, :>=, start
    assert_match(/Morse|Creek|sounding/i, word)

    request = YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0)
    body = request.dig("request", "body", "string")
    assert_includes body, "verbose_json"
    assert_includes body, "timestamp_granularities"
    assert_includes body, "word"
    assert_includes body, "segment"
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
