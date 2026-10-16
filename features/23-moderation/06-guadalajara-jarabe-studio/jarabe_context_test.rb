# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "jarabe_context"

class GuadalajaraJarabeContextTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/jarabe_context.yml", __dir__)

  def test_the_context_pin_leaves_the_global_default
    result = nil
    Multivitamin::Cassettes.play(__dir__, "jarabe_context") do
      result = GuadalajaraJarabeStudio::JarabeContext.conduct
    end

    refute result.flagged
    assert_includes result.model, "omni-moderation-2024-09-26"
    assert_equal "omni-moderation-latest", result.global_default
    assert_includes request_body, "omni-moderation-2024-09-26"
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
