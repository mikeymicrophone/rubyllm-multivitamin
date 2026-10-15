# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "rat_mime"

class RatIslandSpeechMimeTypeTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/rat_mime.yml", __dir__)

  def test_mp3_and_wav_carry_their_mime_types
    result = nil
    Multivitamin::Cassettes.play(__dir__, "rat_mime") do
      result = RatIslandMimeType::RatMime.conduct
    end

    assert_equal "mp3", result.mp3_format
    assert_equal "audio/mpeg", result.mp3_mime
    assert_equal 0xFF, result.mp3_magic

    assert_equal "wav", result.wav_format
    assert_equal "audio/wav", result.wav_mime
    assert_equal "RIFF", result.wav_magic

    bodies = request_bodies
    assert_equal 2, bodies.length
    refute_includes bodies.fetch(0), "response_format"
    assert_includes bodies.fetch(1), '"response_format":"wav"'
    bodies.each { |body| assert_includes body, "Rat Island" }
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map do |interaction|
      interaction.dig("request", "body", "string")
    end
  end
end
