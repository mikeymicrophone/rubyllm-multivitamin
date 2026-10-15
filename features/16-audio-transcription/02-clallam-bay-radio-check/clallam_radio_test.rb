# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "clallam_radio"

class TranscriptionClallamBayRadioCheckTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/clallam_radio.yml", __dir__)

  def test_context_transcribe_uses_whisper_and_leaves_the_global_default
    result = nil
    Multivitamin::Cassettes.play(__dir__, "clallam_radio") do
      result = ClallamBayRadioCheck::RadioCheck.conduct
    end

    assert_equal Multivitamin::Models::OPENAI_TRANSCRIBE_WHISPER, result.model
    assert_equal Multivitamin::Models::OPENAI_TRANSCRIBE_WHISPER, result.context_default
    assert_equal "gpt-transcribe", result.global_default
    refute_equal result.context_default, result.global_default
    assert_equal 90, result.context_timeout
    assert_equal 120, result.global_timeout
    assert_match(/Clall[au]m/i, result.text)
    assert_match(/Calder/i, result.text)

    request = YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0)
    assert_includes request.dig("request", "body", "string"), "whisper-1"
    refute_includes request.dig("request", "body", "string"), "gpt-transcribe"
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
