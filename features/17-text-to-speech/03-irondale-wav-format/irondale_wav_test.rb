# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "irondale_wav"

class IrondaleWavFormatSpeechTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/irondale_wav.yml", __dir__)

  def test_wav_format_writes_riff_bytes
    result = nil
    Multivitamin::Cassettes.play(__dir__, "irondale_wav") do
      result = IrondaleWavFormat::IrondaleWav.conduct
    end

    assert_equal "wav", result.format
    assert_equal "audio/wav", result.mime_type
    assert_equal "RIFF", result.magic
    assert_match(/pile_hail\.wav\z/, result.returned_path)

    request = request_body
    assert_includes request, '"response_format":"wav"'
    assert_includes request, "Irondale"
    assert_equal 1, YAML.load_file(CASSETTE).fetch("http_interactions").length
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
