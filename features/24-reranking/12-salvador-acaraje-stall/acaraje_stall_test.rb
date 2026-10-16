# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "acaraje_stall"

class SalvadorAcarajeStallPipelineTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/acaraje_stall.yml", __dir__)

  def test_the_clerk_briefs_lucia_from_the_winning_stall
    result = nil
    Multivitamin::Cassettes.play(__dir__, "acaraje_stall") do
      result = SalvadorAcarajeStall::AcarajeStall.conduct
    end

    assert_equal 1, result.index
    assert_match(/L[uú]cia/i, result.brief)
    assert_includes result.brief, "07:20"
    assert_equal %i[system user assistant], result.roles
    assert_equal 2, interactions.length
    assert_match(/rerank/, interactions.fetch(0).dig("request", "uri"))
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end

  def interactions
    YAML.load_file(CASSETTE).fetch("http_interactions")
  end
end
