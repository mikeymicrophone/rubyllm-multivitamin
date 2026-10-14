# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "barometer_round"

class BarometerRoundTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/barometer_round.yml", __dir__)

  def test_the_glass_and_the_written_round_travel_together
    result = nil
    Multivitamin::Cassettes.play(__dir__, "barometer_round") do
      result = SmithIslandBarometerRound::BarometerRound.conduct
    end

    assert_includes result.round, "29.84"
    assert_includes result.round, "29.91"
    assert_match(/18/, result.round)
    assert_match(/southwest/i, result.round)
    assert_equal :stop, result.finish
    assert_operator result.cost, :>, 0

    request = request_bodies.fetch(0)
    assert_includes request, '"type":"input_image"'
    assert_includes request, "data:image/png;base64,"
    assert_includes request, "<file name='weather-round.txt' mime_type='text/plain'>"
    assert_includes request, "29.91 inches"
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
