# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "duodji"

class RovaniemiDuodjiDefaultThinkingTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/duodji.yml", __dir__)

  def test_default_thinking_returns_text_and_sends_enabled_true
    result = nil
    Multivitamin::Cassettes.play(__dir__, "duodji") do
      result = RovaniemiDuodjiKnife::DuodjiKnife.conduct
    end

    assert_includes result.brief, "Aila"
    assert_includes result.brief, "08:00"
    refute_nil result.thinking_text
    refute_empty result.thinking_text
    assert result.enabled[:enabled]
    assert_includes request_body, '"enabled":true'
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end

  def request_body
    YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0).dig("request", "body", "string").to_s
  end
end
