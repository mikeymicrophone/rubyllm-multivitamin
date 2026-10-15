# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "schoolyard_round"

class SchoolyardRoundTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/schoolyard_round.yml", __dir__)

  def test_the_glass_and_the_written_round_travel_together
    result = nil
    Multivitamin::Cassettes.play(__dir__, "schoolyard_round") do
      result = RigaSchoolyardRound::SchoolyardRound.conduct
    end

    assert_includes result.round, "-4.2"
    assert_includes result.round, "-1.8"
    assert_match(/9/, result.round)
    assert_match(/east/i, result.round)
    assert_equal :stop, result.finish
    assert_operator result.cost, :>, 0

    request = request_bodies.fetch(0)
    assert_includes request, '"type":"input_image"'
    assert_includes request, "data:image/png;base64,"
    assert_includes request, "<file name='schoolyard-round.txt' mime_type='text/plain'>"
    assert_includes request, "-1.8 C"
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
