# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "harp_sampling"

class AsuncionHarpSamplingParamsTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/harp_sampling.yml", __dir__)

  def test_one_chat_sends_temperature_and_top_p_and_the_other_omits_them
    result = nil
    Multivitamin::Cassettes.play(__dir__, "harp_sampling") do
      result = AsuncionHarpSampling::HarpSampling.conduct
    end

    assert_includes result.held, "31"
    assert_match(/P[aá]jaro/i, result.held)
    assert_includes result.unset, "31"
    assert_match(/P[aá]jaro/i, result.unset)
    assert_equal AsuncionHarpSampling::HarpSampling::HELD_TEMPERATURE, result.held_temperature
    assert_nil result.unset_temperature
    assert_equal AsuncionHarpSampling::HarpSampling::HELD_TOP_P, result.held_options[:top_p]
    assert_empty result.unset_options
    refute result.responds_to_params
    assert result.responds_to_provider_options

    bodies = request_bodies
    held = bodies.find { |body| body.include?("\"top_p\":#{AsuncionHarpSampling::HarpSampling::HELD_TOP_P}") }
    unset = bodies.reject { |body| body.include?("top_p") }
    assert held
    assert_includes held, "\"temperature\":#{AsuncionHarpSampling::HarpSampling::HELD_TEMPERATURE}"
    assert_equal 1, unset.length
    refute_includes unset.first, "temperature"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map do |interaction|
      interaction.dig("request", "body", "string").to_s
    end
  end
end
