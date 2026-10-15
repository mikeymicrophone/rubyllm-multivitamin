# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "mine_face"

class MineFaceTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/mine_face.yml", __dir__)

  def test_the_station_is_taken_from_later_in_the_question
    result = nil
    Multivitamin::Cassettes.play(__dir__, "mine_face") do
      result = HallstattSaltFace::FaceReading.conduct
    end

    assert_match(/hallstatt/i, result.station)
    assert_equal HallstattSaltFace::FaceCard::HALLSTATT_CARD, result.tool_content
    assert_includes result.answer, "38"
    assert_equal %i[system user assistant tool assistant], result.roles

    request = YAML.load_file(CASSETTE).dig("http_interactions", 0, "request", "body", "string")
    refute_includes request, "38 m"
  end

  def test_the_first_sentence_names_the_visitor_office
    first_sentence = HallstattSaltFace::FaceReading::FACE_QUESTION.lines.first

    refute_includes first_sentence, "Hallstatt"
    assert_includes first_sentence, "Salzburg"
    assert_includes HallstattSaltFace::FaceReading::FACE_QUESTION, "Hallstatt"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
    refute_includes cassette, "Bearer sk-"
  end
end
