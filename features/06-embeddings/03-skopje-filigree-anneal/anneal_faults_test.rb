# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "anneal_faults"

class AnnealFaultCosineTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/anneal_faults.yml", __dir__)

  def test_the_torch_echo_outranks_the_burek_log
    result = nil
    Multivitamin::Cassettes.play(__dir__, "anneal_faults") do
      result = SkopjeFiligreeAnneal::AnnealFaults.conduct
    end

    assert_operator result.twin_score, :>, result.cook_score
    assert_operator result.twin_score, :>, 0.7
    assert_operator result.cook_score, :<, 0.5
    assert_equal 3, result.vectors.length
    assert_equal "text-embedding-3-small", result.model_id
    assert_operator result.input_tokens, :>, 0
    assert_operator result.cost, :>, 0

    request = request_bodies.fetch(0)
    assert_includes request, "18 psi"
    assert_includes request, "Burek oven 3"
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
