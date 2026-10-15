# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "kilisut_diarize"

class TranscriptionKilisutHarborDiarizeTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/kilisut_diarize.yml", __dir__)

  def test_diarize_labels_the_kilisut_harbor_voices
    result = nil
    Multivitamin::Cassettes.play(__dir__, "kilisut_diarize") do
      result = KilisutHarborDiarize::HarborWatch.conduct
    end

    assert_equal Multivitamin::Models::OPENAI_TRANSCRIBE_DIARIZE, result.model
    assert_kind_of Array, result.segments
    assert_operator result.segments.length, :>=, 2

    speakers = result.segments.map { |segment| segment["speaker"] || segment[:speaker] }.compact.uniq
    assert_operator speakers.length, :>=, 2

    joined = result.segments.map { |segment| segment["text"] || segment[:text] }.join(" ")
    assert_match(/Kilisut|barometer|Foghorn|visibility/i, joined)
    assert_match(/Kilisut|barometer|Foghorn|visibility/i, result.text.to_s + joined)

    request = YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0)
    body = request.dig("request", "body", "string")
    assert_includes body, "gpt-4o-transcribe-diarize"
    assert_includes body, "diarized_json"
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
