# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "sekiu_hail"

class TranscriptionSekiuSpanishHailTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/sekiu_hail.yml", __dir__)

  def test_language_hint_keeps_the_sekiu_hail_in_spanish
    result = nil
    Multivitamin::Cassettes.play(__dir__, "sekiu_hail") do
      result = SekiuSpanishHail::SpanishHail.conduct
    end

    assert_equal Multivitamin::Models::OPENAI_TRANSCRIBE_WHISPER, result.model
    assert_match(/Sekiu/i, result.text)
    assert_match(/Alden/i, result.text)
    assert_match(/Nea/i, result.text)
    assert_match(/pr[aá]ctic/i, result.text)

    request = YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0)
    assert_includes request.dig("request", "body", "string"), "name=\"language\""
    assert_includes request.dig("request", "body", "string"), "es"
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
