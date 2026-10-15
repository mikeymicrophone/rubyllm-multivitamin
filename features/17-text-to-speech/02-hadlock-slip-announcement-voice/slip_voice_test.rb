# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "slip_voice"

class HadlockSlipAnnouncementVoiceSpeechTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/slip_voice.yml", __dir__)

  def test_voice_nova_is_on_the_hadlock_payload
    result = nil
    Multivitamin::Cassettes.play(__dir__, "slip_voice") do
      result = HadlockSlipAnnouncementVoice::SlipVoice.conduct
    end

    assert_equal "nova", result.voice
    assert_equal "tts-1", result.model
    assert_equal "audio/mpeg", result.mime_type

    request = request_body
    assert_includes request, '"voice":"nova"'
    assert_includes request, "Hadlock"
    assert_includes request, "Khutzeymateen"
    refute_includes request, '"voice":"alloy"'
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
