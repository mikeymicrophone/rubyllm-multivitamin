# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "cape_george_answer"

class CapeGeorgeSpokenChatAnswerTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/cape_george_answer.yml", __dir__)

  def test_the_spoken_clip_is_the_chat_answer
    result = nil
    Multivitamin::Cassettes.play(__dir__, "cape_george_answer") do
      result = CapeGeorgeSpokenAnswer::CapeGeorgeAnswer.conduct
    end

    assert_includes result.answer, "Cape George"
    assert_includes result.answer, "Alden"
    assert_equal "tts-1", result.speech_model
    assert_equal %i[system user assistant], result.roles
    assert_operator result.spoken_bytes, :>, 0

    bodies = request_bodies
    assert_equal 2, bodies.length
    assert_includes bodies.fetch(0), '"model":"gpt-4.1-mini"'
    assert_includes bodies.fetch(0), "Cape George"
    assert_includes bodies.fetch(1), '"model":"tts-1"'
    assert_includes bodies.fetch(1), result.answer
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
