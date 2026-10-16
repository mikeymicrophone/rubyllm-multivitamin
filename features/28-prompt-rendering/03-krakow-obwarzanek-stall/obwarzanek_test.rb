# frozen_string_literal: true

require "minitest/autorun"
require_relative "obwarzanek"

class KrakowObwarzanekStallTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/obwarzanek.yml", __dir__)

  def test_the_static_prompt_names_zofia
    result = nil
    Multivitamin::Cassettes.play(__dir__, "obwarzanek") do
      result = KrakowObwarzanekStall::ObwarzanekStall.conduct
    end

    assert_includes result.rendered, "Zofia"
    refute_includes result.rendered, "<%="
    assert_includes result.brief, "Zofia"
    assert_includes result.brief, "06:40"
    assert_equal %i[system user assistant], result.roles
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
