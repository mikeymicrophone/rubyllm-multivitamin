# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "sidama"

class HawassaSidamaAgentThinkingTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/sidama.yml", __dir__)

  def test_the_agent_macro_sends_summarized_low_effort
    result = nil
    Multivitamin::Cassettes.play(__dir__, "sidama") do
      result = HawassaSidamaCoffee::SidamaCoffee.conduct
    end

    assert_includes result.brief, "Tigist"
    assert_includes result.brief, "06:20"
    assert_equal "HawassaSidamaCoffee::MillClerk", result.agent_class
    assert_includes request_body, '"effort":"medium"'
    assert_includes request_body, '"summary":"auto"'
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_body
    YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0).dig("request", "body", "string").to_s
  end
end
