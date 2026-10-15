# frozen_string_literal: true

require "minitest/autorun"
require_relative "kelp_ledge_tokens"

class PointWilsonKelpLedgeTokenCountTest < Minitest::Test
  def test_input_and_output_token_counts_are_integers
    result = nil
    Multivitamin::Cassettes.play(__dir__, "kelp_ledge_tokens") do
      result = PointWilsonKelpLedgeTokens::KelpLedgeTokens.conduct
    end

    assert_includes result.brief, "Alden"
    assert_includes result.brief, "10:46"
    assert_equal %i[system user assistant], result.roles
    assert_equal :stop, result.finish
    assert_instance_of Integer, result.input_tokens
    assert_instance_of Integer, result.output_tokens
    assert_operator result.input_tokens, :>, 0
    assert_operator result.output_tokens, :>, 0
    assert_equal 0, result.cost_total
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/kelp_ledge_tokens.yml", __dir__))

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
