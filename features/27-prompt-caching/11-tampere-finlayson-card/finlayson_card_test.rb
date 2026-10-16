# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "finlayson_card"

class TampereFinlaysonCardAgentTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/finlayson_card.yml", __dir__)

  def test_the_agent_macro_sends_a_one_hour_ttl
    result = nil
    Multivitamin::Cassettes.play(__dir__, "finlayson_card") do
      result = TampereFinlaysonCard::FinlaysonCard.conduct
    end

    assert_includes result.brief, "Aino"
    assert_includes result.brief, "07:00"
    assert_equal "TampereFinlaysonCard::MillClerk", result.agent_class
    assert_includes request_body, '"ttl":"1h"'
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
