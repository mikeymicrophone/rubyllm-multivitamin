# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "middle_refusal"

class MiddlePointRefusedFormatSpeechTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/middle_refusal.yml", __dir__)

  def test_aiff_raises_and_names_the_invalid_format
    result = nil
    Multivitamin::Cassettes.play(__dir__, "middle_refusal") do
      result = MiddlePointRefusedFormat::MiddleRefusal.conduct
    end

    assert_equal RubyLLM::BadRequestError, result.error_class
    assert_includes result.message, "Invalid response_format"

    interaction = YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0)
    assert_equal 400, interaction.dig("response", "status", "code")
    assert_includes interaction.dig("request", "body", "string"), '"response_format":"aiff"'
    assert_includes interaction.dig("request", "body", "string"), "Middle Point"
    refute_equal 0xFF, interaction.dig("response", "body", "string").to_s.getbyte(0)
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
