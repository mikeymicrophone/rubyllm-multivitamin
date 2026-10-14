# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "chart_size_refusal"

class JuanDeFucaChartSizeRefusalTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/chart_size_refusal.yml", __dir__)

  def test_two_fifty_six_raises_and_names_the_supported_sizes
    result = nil
    Multivitamin::Cassettes.play(__dir__, "chart_size_refusal") do
      result = JuanDeFucaChartSizeRefusal::ChartSizeRefusal.conduct
    end

    assert_equal RubyLLM::BadRequestError, result.error_class
    assert_includes result.message, "256x256"
    assert_includes result.message, "1024x1024"
    assert_includes result.message, "1536x1024"
    assert_includes result.message, "1024x1536"

    interaction = YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0)
    assert_equal 400, interaction.dig("response", "status", "code")
    assert_includes interaction.dig("request", "body", "string"), '"size":"256x256"'
    assert_includes interaction.dig("request", "body", "string"), "18465"
    refute_includes interaction.dig("response", "body", "string").to_s, "b64_json"
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
