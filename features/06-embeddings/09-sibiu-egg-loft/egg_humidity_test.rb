# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "egg_humidity"

class EggHumidityRankTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/egg_humidity.yml", __dir__)

  def test_the_loft_paraphrase_outranks_the_eave
    result = nil
    Multivitamin::Cassettes.play(__dir__, "egg_humidity") do
      result = SibiuEggLoft::EggHumidity.conduct
    end

    assert_operator result.paraphrase_score, :>, result.crane_score
    assert_operator result.paraphrase_score, :>, 0.4
    assert_equal "text-embedding-3-small", result.model_id
    assert_operator result.input_tokens, :>, 0
    assert_operator result.cost, :>, 0

    request = request_bodies.fetch(0)
    assert_includes request, "14 percent above the chalk"
    assert_includes request, "flashing"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map do |interaction|
      interaction.dig("request", "body", "string").to_s
    end
  end
end
