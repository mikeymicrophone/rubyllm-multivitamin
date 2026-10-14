# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "cook_procedure"

class CookProcedureTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/cook_procedure.yml", __dir__)

  def test_the_procedure_stays_inline
    result = nil
    Multivitamin::Cassettes.play(__dir__, "cook_procedure") do
      result = AnacortesRetortProcedure::CookProcedure.conduct
    end

    assert_includes result.card, "3"
    assert_includes result.card, "242"
    assert_includes result.card, "75"
    assert_operator result.byte_size, :>, 0
    assert_operator result.byte_size, :<, result.inline_limit
    assert_equal 52_428_800, result.inline_limit
    assert_equal :stop, result.finish
    assert_operator result.input_tokens, :>, 0
    assert_operator result.cost, :>, 0

    request = request_bodies.fetch(0)
    assert_includes request, '"type":"input_file"'
    assert_includes request, '"file_data":"data:application/pdf;base64,'
    refute_includes request, "file_id"
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
