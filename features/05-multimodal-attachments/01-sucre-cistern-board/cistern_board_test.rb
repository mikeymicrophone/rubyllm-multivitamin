# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "cistern_board"

class CisternBoardPhotoTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/cistern_board.yml", __dir__)

  def test_the_photograph_is_the_board
    result = nil
    Multivitamin::Cassettes.play(__dir__, "cistern_board") do
      result = SucreCisternBoardPhoto::CisternBoard.conduct
    end

    assert_includes result.brief, "05:20"
    assert_includes result.brief, "1.6"
    assert_includes result.brief, "07:45"
    assert_match(/Rosa/i, result.brief)
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
