# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "welcome_hail"

class FortWordenWelcomeHailSpeechTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/welcome_hail.yml", __dir__)

  def test_speak_returns_speech_of_the_spit_hail
    result = nil
    Multivitamin::Cassettes.play(__dir__, "welcome_hail") do
      result = FortWordenWelcomeHail::WelcomeHail.conduct
    end

    assert_instance_of RubyLLM::Speech, result.speech
    assert_equal "tts-1", result.model
    assert_equal "alloy", result.voice
    assert_equal "mp3", result.format
    assert_equal "audio/mpeg", result.mime_type
    assert_equal 0xFF, result.speech.to_blob.getbyte(0)

    request = request_body
    assert_includes request, '"model":"tts-1"'
    assert_includes request, '"voice":"alloy"'
    assert_includes request, "Fort Worden"
    refute_includes request, "response_format"
    assert_equal "https://api.openai.com/v1/audio/speech", request_uri
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)

    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_uri
    YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0).dig("request", "uri")
  end

  def request_body
    YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0).dig("request", "body", "string")
  end
end
