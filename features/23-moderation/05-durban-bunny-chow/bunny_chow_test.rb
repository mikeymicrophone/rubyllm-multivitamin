# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "bunny_chow"

class DurbanBunnyChowPinnedModelTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/bunny_chow.yml", __dir__)

  def test_the_pinned_model_screens_the_clean_counter
    result = nil
    Multivitamin::Cassettes.play(__dir__, "bunny_chow") do
      result = DurbanBunnyChow::BunnyChow.conduct
    end

    refute result.flagged
    assert_includes result.model, "omni-moderation-2024-09-26"
    assert_includes request_body, result.requested
    refute_includes request_body, "omni-moderation-latest"
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
