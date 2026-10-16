# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "gara_cloth"

class FreetownGaraClothToolTokensTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/gara_cloth.yml", __dir__)

  def test_the_tool_round_still_has_input_and_output_counts
    result = nil
    Multivitamin::Cassettes.play(__dir__, "gara_cloth") do
      result = FreetownGaraCloth::GaraCloth.conduct
    end

    assert_match(/unknown keyword: \w+/, result.tool_contents.first)
    assert_equal FreetownGaraCloth::PostedGaraCard::CARD, result.tool_contents.last
    assert_includes result.answer, "14"
    assert_includes result.answer, "Lumley"
    assert_equal %i[system user assistant tool assistant tool assistant], result.roles
    assert_operator result.answer_input, :>, 0
    assert_operator result.answer_output, :>, 0
    assert_equal 0, result.answer_cost
    assert_operator result.chat_input, :>=, result.answer_input
    assert_operator result.attempts, :>=, 2
    assert_equal 0, result.chat_cost

    request = YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0).dig("request", "body", "string")
    assert_includes request, '"name":"posted_gara_card"'
    refute_includes request, "14 yards"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
