# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "sill_depth"

class SillDepthTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/sill_depth.yml", __dir__)

  def test_the_station_is_taken_from_later_in_the_question
    skip "cassette pending live recording" unless File.exist?(CASSETTE) || Multivitamin::Cassettes.live?

    result = nil
    Multivitamin::Cassettes.play(__dir__, "sill_depth") do
      result = BremertonDryDockSill::SillReading.conduct
    end

    assert_match(/bremerton/i, result.station)
    assert_equal BremertonDryDockSill::SillCard::BREMERTON_CARD, result.tool_content
    assert_includes result.answer, "38"
    assert_equal %i[system user assistant tool assistant], result.roles

    request = YAML.load_file(CASSETTE).dig("http_interactions", 0, "request", "body", "string")
    refute_includes request, "38 ft"
  end

  def test_the_first_sentence_names_the_barge
    first_sentence = BremertonDryDockSill::SillReading::SILL_QUESTION.lines.first

    refute_includes first_sentence, "Bremerton"
    assert_includes first_sentence, "Kulshan"
    assert_includes BremertonDryDockSill::SillReading::SILL_QUESTION, "Bremerton"
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette pending live recording" unless File.exist?(CASSETTE)

    cassette = File.read(CASSETTE)

    refute_match(/sk-or-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
