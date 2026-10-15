# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "tatoosh_foghorn"

class TranscriptionTatooshFoghornTapeTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/tatoosh_foghorn.yml", __dir__)

  def test_transcribe_returns_the_tatoosh_horn_tape
    result = nil
    Multivitamin::Cassettes.play(__dir__, "tatoosh_foghorn") do
      result = TatooshFoghornTape::FoghornTape.conduct
    end

    assert_equal "RubyLLM::Transcription", result.klass
    assert_equal Multivitamin::Models::OPENAI_TRANSCRIBE, result.model
    assert_match(/Tatou/i, result.text)
    assert_match(/Alden/i, result.text)
    assert_match(/blast/i, result.text)

    request = YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0)
    assert_equal "https://api.openai.com/v1/audio/transcriptions", request.dig("request", "uri")
    assert_includes request.dig("request", "body", "string"), "gpt-transcribe"
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
