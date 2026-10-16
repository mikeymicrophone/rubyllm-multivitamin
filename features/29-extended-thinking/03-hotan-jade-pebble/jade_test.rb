# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "jade"

class HotanJadeBudgetTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/jade.yml", __dir__)

  def test_budget_is_omitted_on_openai_and_sent_on_nemotron
    result = nil
    Multivitamin::Cassettes.play(__dir__, "jade") do
      result = HotanJadePebble::JadePebble.conduct
    end

    assert_includes result.openai_brief, "Gulnisa"
    assert_includes result.openrouter_brief, "Gulnisa"
    assert_equal 1024, result.openai_budget[:budget]
    assert_equal 1024, result.openrouter_budget[:budget]
    refute_includes openai_body, "1024"
    assert_includes openrouter_body, '"max_tokens":1024'
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end

  def openai_body
    interactions.fetch(0).dig("request", "body", "string").to_s
  end

  def openrouter_body
    interactions.fetch(1).dig("request", "body", "string").to_s
  end

  def interactions
    YAML.load_file(CASSETTE).fetch("http_interactions")
  end
end
