# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "indian_speakers"

class TranscriptionIndianIslandSpeakersTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/indian_speakers.yml", __dir__)

  def test_named_references_label_alden_and_calder
    result = nil
    Multivitamin::Cassettes.play(__dir__, "indian_speakers") do
      result = IndianIslandSpeakers::KnownVoices.conduct
    end

    assert_equal Multivitamin::Models::OPENAI_TRANSCRIBE_DIARIZE, result.model
    assert_kind_of Array, result.segments
    assert_operator result.segments.length, :>=, 1
    joined = Array(result.segments).map { |segment| segment["text"] || segment[:text] }.join(" ")
    assert_match(/Indian|Retort|pier|boom/i, "#{result.text} #{joined}")

    request = YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0)
    body = request.dig("request", "body", "string")
    assert_includes body, "known_speaker_names"
    assert_includes body, "Alden"
    assert_includes body, "Calder"
    assert_includes body, "known_speaker_references"
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
