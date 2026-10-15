# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "wool_refusal"

class WoolRefusalTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/wool_refusal.yml", __dir__)

  def test_the_workbook_stops_locally_and_the_lot_is_refused
    result = nil
    Multivitamin::Cassettes.play(__dir__, "wool_refusal") do
      result = MontevideoWoolRefusal::WoolRefusal.conduct
    end

    assert_instance_of RubyLLM::UnsupportedAttachmentError, result.workbook_error
    assert_includes result.workbook_error.message, result.workbook_mime
    assert_includes result.workbook_mime, "spreadsheetml.sheet"
    assert_nil result.workbook_error.response

    assert_instance_of RubyLLM::BadRequestError, result.audio_error
    assert_equal 400, result.audio_status
    assert_match(/image_url/, result.audio_error.message)
    assert_equal 1, result.workbook_converter_calls
    assert_equal 0, result.audio_converter_calls

    assert_equal 1, interactions.length
    assert_equal 400, interactions.fetch(0).dig("response", "status", "code")
    request = request_bodies.fetch(0)
    assert_includes request, '"type":"input_audio"'
    assert_includes request, '"model":"gpt-4.1-mini"'
    refute_includes request, "spreadsheetml"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    interactions.map { |interaction| interaction.dig("request", "body", "string").to_s.dup.force_encoding(Encoding::UTF_8) }
  end

  def interactions
    YAML.load_file(CASSETTE).fetch("http_interactions")
  end
end
