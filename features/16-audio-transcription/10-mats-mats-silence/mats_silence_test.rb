# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "mats_silence"

class TranscriptionMatsMatsSilenceTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/mats_silence.yml", __dir__)

  def test_silent_reel_returns_an_empty_transcript
    result = nil
    Multivitamin::Cassettes.play(__dir__, "mats_silence") do
      result = MatsMatsSilence::SilentReel.conduct
    end

    assert_equal Multivitamin::Models::OPENAI_TRANSCRIBE, result.model
    assert result.blank
    assert_equal "", result.text.to_s.strip

    interactions = YAML.load_file(CASSETTE).fetch("http_interactions")
    assert_equal 1, interactions.length
    assert_equal 200, interactions.fetch(0).dig("response", "status", "code")
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
