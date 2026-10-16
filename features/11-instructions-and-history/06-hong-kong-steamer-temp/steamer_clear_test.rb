# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "steamer_clear"

class HongKongSteamerTempTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/steamer_clear.yml", __dir__)

  def test_temperature_clears_between_rounds
    result = nil
    Multivitamin::Cassettes.play(__dir__, "steamer_clear") do
      result = HongKongSteamerTemp::SteamerClear.conduct
    end

    assert_equal 0.1, result.held_temperature
    assert_nil result.cleared_temperature
    assert_match(/\A\s*Yes\b/i, result.siu_mai.to_s)
    assert_match(/hold/i, result.siu_mai)
    assert_match(/\A\s*Yes\b/i, result.har_gow.to_s)
    assert_includes result.har_gow, "18"
    assert_equal %i[system user assistant user assistant], result.roles
  end

  def test_second_request_omits_temperature
    first, second = request_bodies

    assert_includes first, '"temperature":0.1'
    refute_includes second, '"temperature"'
    assert_includes second, "har-gow"
    assert_includes second, "siu-mai"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map { |hit|
      hit.dig("request", "body", "string")
    }
  end
end
