# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "tide_board"

class TideBoardPhotoTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/tide_board.yml", __dir__)

  def test_the_photograph_is_the_board
    result = nil
    Multivitamin::Cassettes.play(__dir__, "tide_board") do
      result = PointWilsonTideBoardPhoto::TideBoard.conduct
    end

    assert_includes result.brief, "06:42"
    assert_includes result.brief, "0.4"
    assert_includes result.brief, "10:46"
    assert_match(/Alden/i, result.brief)
    assert_equal %i[system user assistant], result.roles
    assert_equal :stop, result.finish
    assert_operator result.input_tokens, :>, 0
    assert_operator result.output_tokens, :>, 0
    assert_operator result.cost, :>, 0

    request = request_bodies.fetch(0)
    assert_includes request, '"model":"gpt-4.1-mini"'
    assert_includes request, '"type":"input_image"'
    assert_includes request, "data:image/png;base64,"
    refute_includes request, "https://upload.wikimedia.org"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
    refute_includes cassette, "Bearer sk-"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map do |interaction|
      interaction.dig("request", "body", "string").to_s.dup.force_encoding(Encoding::UTF_8)
    end
  end
end
