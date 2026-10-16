# frozen_string_literal: true

require "minitest/autorun"
require_relative "copper_pot"

class MostarCopperPotNestedTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/copper_pot.yml", __dir__)

  def test_the_nested_path_and_the_full_filename_match
    result = nil
    Multivitamin::Cassettes.play(__dir__, "copper_pot") do
      result = MostarCopperPot::CopperPot.conduct
    end

    assert_equal result.nested, result.full_name
    assert_includes result.nested, "Emir"
    assert_includes result.nested, "MST-2026-1016-C5"
    assert_includes result.brief, "Emir"
    assert_includes result.brief, "10:20"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
