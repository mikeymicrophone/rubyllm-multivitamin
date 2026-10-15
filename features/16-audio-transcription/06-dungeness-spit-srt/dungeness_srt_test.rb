# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "dungeness_srt"

class TranscriptionDungenessSpitSrtTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/dungeness_srt.yml", __dir__)

  def test_srt_format_returns_a_subtitle_card_for_the_bell_buoy
    result = nil
    Multivitamin::Cassettes.play(__dir__, "dungeness_srt") do
      result = DungenessSpitSrt::SpitCard.conduct
    end

    assert_equal Multivitamin::Models::OPENAI_TRANSCRIBE_WHISPER, result.model
    assert_match(/Dungeness/i, result.text)
    assert_match(/northwest/i, result.text)
    assert_match(/^\s*1\s*$/m, result.text)
    assert_match(/\d{2}:\d{2}:\d{2},\d{3}\s+-->\s+\d{2}:\d{2}:\d{2},\d{3}/, result.text)

    request = YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0)
    assert_includes request.dig("request", "body", "string"), "name=\"response_format\""
    assert_includes request.dig("request", "body", "string"), "srt"
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
