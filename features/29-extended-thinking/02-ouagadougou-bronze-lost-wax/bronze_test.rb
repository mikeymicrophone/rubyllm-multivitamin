# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "bronze"

class OuagadougouBronzeEffortTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/bronze.yml", __dir__)

  def test_effort_low_is_on_the_wire_and_the_brief_names_aminata
    result = nil
    Multivitamin::Cassettes.play(__dir__, "bronze") do
      result = OuagadougouBronzeLostWax::BronzeLostWax.conduct
    end

    assert_includes result.brief, "Aminata"
    assert_includes result.brief, "07:30"
    assert_equal :low, result.effort[:effort]
    assert_includes request_body, '"effort":"low"'
    refute_includes request_body, "temperature"
    assert_nil result.thinking_text
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
