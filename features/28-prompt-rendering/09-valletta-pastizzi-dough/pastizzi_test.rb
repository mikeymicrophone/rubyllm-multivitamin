# frozen_string_literal: true

require "minitest/autorun"
require_relative "pastizzi"

class VallettaPastizziDoughAllowlistTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/pastizzi.yml", __dir__)

  def test_the_known_card_renders_and_the_traversal_never_reaches_erb
    result = nil
    Multivitamin::Cassettes.play(__dir__, "pastizzi") do
      result = VallettaPastizziDough::PastizziDesk.conduct
    end

    assert_includes result.rendered, "Lucia"
    assert_includes result.brief, "Lucia"
    assert_includes result.brief, "07:10"
    assert_instance_of ArgumentError, result.unknown
    assert_match(/unknown stall card/, result.unknown.message)
    refute_match(/Prompt file not found/, result.unknown.message)
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
