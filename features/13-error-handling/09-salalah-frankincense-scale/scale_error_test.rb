# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "yaml"
require_relative "scale_error"

class SalalahFrankincenseScaleToolErrorTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/scale_error.yml", __dir__)

  def test_the_offline_scale_returns_to_the_model_and_the_lamp_raises
    result = nil
    Multivitamin::Cassettes.play(__dir__, "scale_error") do
      result = SalalahFrankincenseScale::ScaleError.conduct
    end

    parsed = JSON.parse(result.tool_content)
    assert_equal "Salalah beam-scale offline since 04:10. Weigh the Hojari lot on the hand-beam.", parsed["error"]
    assert_includes result.brief, "04:10"
    assert_match(/hand-beam/i, result.brief)
    assert_equal %i[system user assistant tool assistant], result.roles

    assert_instance_of SalalahFrankincenseScale::ScaleHouseDark, result.lamp_error
    refute result.lamp_is_llm_error
    assert_includes result.lamp_error.message, "lamp"

    bodies = request_bodies
    assert_includes bodies.fetch(0), '"name":"salalah_beam_scale"'
    assert_includes bodies.fetch(-1), '"name":"scale_house_lamp"'
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map do |hit|
      hit.dig("request", "body", "string").to_s
    end
  end
end
