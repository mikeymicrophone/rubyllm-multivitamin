# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "kala_speed"

class KalaPointSpeedInstructionsSpeechTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/kala_speed.yml", __dir__)

  def test_instructions_and_speed_are_on_the_payload
    result = nil
    Multivitamin::Cassettes.play(__dir__, "kala_speed") do
      result = KalaPointSpeedInstructions::KalaSpeed.conduct
    end

    assert_equal "tts-1", result.model
    assert_equal "alloy", result.voice
    assert_equal "mp3", result.format

    request = request_body
    assert_includes request, '"instructions":"Speak slowly, as a calm bluff watch copying a card."'
    assert_includes request, '"speed":0.85'
    assert_includes request, "Kala Point"
    assert_includes request, '"model":"tts-1"'
    assert_includes request, '"voice":"alloy"'
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_body
    YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0).dig("request", "body", "string")
  end
end
