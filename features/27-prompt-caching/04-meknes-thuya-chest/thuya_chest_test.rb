# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "thuya_chest"

class MeknesThuyaChestOffSwitchTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/thuya_chest.yml", __dir__)

  def test_false_leaves_prompt_cache_options_off_the_wire
    result = nil
    Multivitamin::Cassettes.play(__dir__, "thuya_chest") do
      result = MeknesThuyaChest::ThuyaChest.conduct
    end

    assert_includes result.brief, "Fatima"
    assert_includes result.brief, "09:20"
    assert_instance_of ArgumentError, result.nil_error
    refute_includes request_body, "prompt_cache_options"
    refute_includes request_body, "prompt_cache_key"
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
