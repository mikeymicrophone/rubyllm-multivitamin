# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "demerara_pan"

class GeorgetownDemeraraPanTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/demerara_pan.yml", __dir__)

  def test_the_caption_and_pan_are_not_flagged
    result = nil
    Multivitamin::Cassettes.play(__dir__, "demerara_pan") do
      result = GeorgetownDemeraraPan::DemeraraPan.conduct
    end

    refute result.flagged
    assert_empty result.categories
    assert_includes request_body, "Georgetown"
    assert_match(/image_url|image\//, request_body)
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
