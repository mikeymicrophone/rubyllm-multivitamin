# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "oak_bay_voices"

class OakBayNovaVsAlloyVoiceTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/oak_bay_voices.yml", __dir__)

  def test_nova_then_alloy_are_named_on_the_wire
    result = nil
    Multivitamin::Cassettes.play(__dir__, "oak_bay_voices") do
      result = OakBayNovaVsAlloy::OakBayVoices.conduct
    end

    assert_equal "nova", result.nova_voice
    assert_equal "alloy", result.alloy_voice
    assert_equal "tts-1", result.nova_model
    assert_equal "tts-1", result.alloy_model

    bodies = request_bodies
    assert_equal 2, bodies.length
    assert_includes bodies.fetch(0), '"voice":"nova"'
    assert_includes bodies.fetch(1), '"voice":"alloy"'
    bodies.each do |body|
      assert_includes body, "Oak Bay"
      assert_includes body, "Alden"
      assert_includes body, '"model":"tts-1"'
    end
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
