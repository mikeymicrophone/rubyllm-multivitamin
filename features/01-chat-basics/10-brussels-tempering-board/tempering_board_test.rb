# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "tempering_board"

class TemperingBoardTest < Minitest::Test
  def test_one_chat_sets_sampling_and_the_other_leaves_it_unset
    result = nil
    Multivitamin::Cassettes.play(__dir__, "tempering_board") do
      result = BrusselsTempering::TemperingBoard.conduct
    end

    assert_equal 0.1, result.held_temperature
    assert_nil result.unset_temperature
    assert_equal BrusselsTempering::TemperingBoard::HELD_OUTPUT_CAP, result.held_output_cap
    assert_nil result.unset_output_cap

    assert_includes result.held, "31"
    assert_includes result.held, "Praliné Roi"
    assert_match(/hold/i, result.held)
    assert_includes result.unset, "31"
    assert_includes result.unset, "Praliné Roi"
    assert_match(/hold/i, result.unset)
  end

  def test_the_unset_chat_omits_temperature_and_the_output_cap_on_the_wire
    cassette = YAML.load_file(File.expand_path("cassettes/tempering_board.yml", __dir__))
    bodies = cassette.fetch("http_interactions").map { |interaction| interaction.dig("request", "body", "string") }

    capped = bodies.find { |body| body.include?("\"max_tokens\":#{BrusselsTempering::TemperingBoard::HELD_OUTPUT_CAP}") }
    unset = bodies.reject { |body| body.include?("max_tokens") }

    assert capped
    assert_includes capped, "\"temperature\":0.1"
    assert_equal 1, unset.length
    refute_includes unset.first, "temperature"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/tempering_board.yml", __dir__))

    refute_match(/sk-or-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
