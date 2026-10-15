# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "shine_tokens"

class TranscriptionShineTidalTokensTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/shine_tokens.yml", __dir__)

  def test_shine_tidal_tape_reports_tokens
    result = nil
    Multivitamin::Cassettes.play(__dir__, "shine_tokens") do
      result = ShineTidalTokens::BridgeTape.conduct
    end

    assert_equal Multivitamin::Models::OPENAI_TRANSCRIBE, result.model
    assert_match(/Shine/i, result.text)
    assert_match(/Hood Canal|barge/i, result.text)
    assert_operator result.duration, :>, 0
    assert_nil result.input_tokens
    assert_nil result.output_tokens
    assert_nil result.cost_total

    body = YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0).dig("response", "body", "string")
    assert_includes body, '"type":"duration"'
    assert_includes body, '"seconds":'
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
