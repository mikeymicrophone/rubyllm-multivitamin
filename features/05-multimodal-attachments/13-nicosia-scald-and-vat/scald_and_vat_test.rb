# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "scald_and_vat"

class ScaldAndVatTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/scald_and_vat.yml", __dir__)

  def test_the_board_and_the_procedure_share_one_model
    result = nil
    Multivitamin::Cassettes.play(__dir__, "scald_and_vat") do
      result = NicosiaScaldAndVat::ScaldAndVat.conduct
    end

    assert_includes result.brief, "08:50"
    assert_includes result.brief, "40"
    assert_match(/Eleni/i, result.brief)
    assert_equal %i[image pdf], result.attachment_types
    assert_equal :stop, result.finish
    assert_operator result.input_tokens, :>, 0
    assert_operator result.cost, :>, 0

    request = request_bodies.fetch(0)
    assert_includes request, '"model":"gpt-4.1-mini"'
    assert_includes request, '"type":"input_image"'
    assert_includes request, "data:image/png;base64,"
    assert_includes request, '"type":"input_file"'
    assert_includes request, "data:application/pdf;base64,"
    assert_equal ["https://api.openai.com/v1/responses"], request_uris
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    interactions.map { |interaction| interaction.dig("request", "body", "string").to_s.dup.force_encoding(Encoding::UTF_8) }
  end

  def request_uris
    interactions.map { |interaction| interaction.dig("request", "uri") }
  end

  def interactions
    YAML.load_file(CASSETTE).fetch("http_interactions")
  end
end
