# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "freshwater_vocab"

class TranscriptionFreshwaterBayVocabularyTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/freshwater_vocab.yml", __dir__)

  def test_prompt_carries_the_freshwater_bay_chart_names
    result = nil
    Multivitamin::Cassettes.play(__dir__, "freshwater_vocab") do
      result = FreshwaterBayVocabulary::VocabularyPrompt.conduct
    end

    assert_equal Multivitamin::Models::OPENAI_TRANSCRIBE, result.model
    assert_match(/Dungeness/i, result.text)
    assert_match(/kelp/i, result.text)
    assert_match(/Fresnel/i, result.text)

    request = YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0)
    body = request.dig("request", "body", "string")
    assert_includes body, "name=\"prompt\""
    assert_includes body, "Dungeness Spit"
    assert_includes body, "kelp ledge"
    assert_includes body, "MLLW"
    assert_includes body, "Fresnel"
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
