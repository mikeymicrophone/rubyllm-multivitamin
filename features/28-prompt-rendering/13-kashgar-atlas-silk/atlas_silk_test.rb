# frozen_string_literal: true

require "minitest/autorun"
require_relative "atlas_silk"

class KashgarAtlasSilkCapstoneTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/atlas_silk.yml", __dir__)

  def test_the_auto_loaded_prompt_holds_for_the_follow_up
    result = nil
    Multivitamin::Cassettes.play(__dir__, "atlas_silk") do
      result = KashgarAtlasSilk::AtlasSilk.conduct
    end

    assert_includes result.system, "Be warm and direct with Dilber"
    assert_includes result.system, "do not mix the warp with the weft"
    assert_includes result.opening, "Dilber"
    assert_includes result.opening, "11:05"
    assert_match(/\ANo\b/, result.follow_up)
    assert_equal %i[system user assistant user assistant], result.roles
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
