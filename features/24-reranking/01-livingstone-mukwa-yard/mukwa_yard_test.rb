# frozen_string_literal: true

require "minitest/autorun"
require_relative "mukwa_yard"

class LivingstoneMukwaYardTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/mukwa_yard.yml", __dir__)

  def test_the_mukwa_stack_lands_first
    result = nil
    Multivitamin::Cassettes.play(__dir__, "mukwa_yard") do
      result = LivingstoneMukwaYard::MukwaYard.conduct
    end

    assert_equal 2, result.index
    assert_includes result.document, "mukwa"
    assert_operator result.score, :>, 0
    assert_equal 4, result.count
    assert_includes result.model, "rerank"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
