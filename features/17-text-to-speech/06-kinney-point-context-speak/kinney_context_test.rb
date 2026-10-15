# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "kinney_context"

class KinneyPointContextSpeakTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/kinney_context.yml", __dir__)

  def test_context_speak_uses_the_tenant_default
    result = nil
    Multivitamin::Cassettes.play(__dir__, "kinney_context") do
      result = KinneyPointContextSpeak::KinneyContext.conduct
    end

    assert_equal "tts-1", result.context_model
    assert_equal "tts-1", result.context_default
    assert_equal "alloy", result.context_voice
    assert_equal "audio/mpeg", result.context_mime
    refute_equal result.context_default, result.global_default

    request = request_body
    assert_includes request, '"model":"tts-1"'
    assert_includes request, "Kinney Point"
    assert_includes request, "Marrowstone"
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
