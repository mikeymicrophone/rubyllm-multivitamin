# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "pilot_ladder"

class PilotLadderTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/pilot_ladder.yml", __dir__)

  def test_both_photographs_are_in_the_one_ask
    result = nil
    Multivitamin::Cassettes.play(__dir__, "pilot_ladder") do
      result = NeahBayLadderPhotographs::PilotLadder.conduct
    end

    assert_includes result.report, "12"
    assert_includes result.report, "7"
    assert_match(/rung/i, result.report)
    assert_equal :stop, result.finish
    assert_operator result.input_tokens, :>, 0
    assert_operator result.cost, :>, 0

    request = request_bodies.fetch(0)
    assert_equal 2, request.scan('"type":"input_image"').length
    assert_equal 2, request.scan("data:image/png;base64,").length
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map do |interaction|
      interaction.dig("request", "body", "string").to_s.dup.force_encoding(Encoding::UTF_8)
    end
  end
end
