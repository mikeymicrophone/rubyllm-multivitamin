# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "toub"

class OmdurmanToubProviderSwitchTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/toub.yml", __dir__)

  def test_the_openrouter_follow_up_drops_the_openai_signature
    result = nil
    Multivitamin::Cassettes.play(__dir__, "toub") do
      result = OmdurmanToubCloth::ToubCloth.conduct
    end

    assert_includes result.opening, "Sittina"
    assert_includes result.follow_up, "OMD-2026-1016-T9"
    refute_nil result.opening_signature
    refute_includes follow_body, result.opening_signature
    refute_includes follow_body, "encrypted_content"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end

  def follow_body
    YAML.load_file(CASSETTE).fetch("http_interactions").fetch(1).dig("request", "body", "string").to_s
  end
end
