# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "cigar_plate"

class CigarFloorJpegPlateTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/cigar_plate.yml", __dir__)
  JPEG_MAGIC = "\xFF\xD8\xFF".b

  def test_jpeg_bytes_arrive_under_a_png_mime_type
    result = nil
    Multivitamin::Cassettes.play(__dir__, "cigar_plate") do
      result = HavanaCigarFloorPlate::CigarPlate.conduct
    end

    assert_equal "image/png", result.mime_type
    assert_equal JPEG_MAGIC, result.magic
    assert result.base64

    request = request_body
    assert_includes request, '"output_format":"jpeg"'
    assert_includes request, '"quality":"low"'
    assert_includes request, "HAB-14-OCT-26"

    response = response_body
    assert_includes response, '"output_format":"jpeg"'
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_body
    YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0).dig("request", "body", "string")
  end

  def response_body
    YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0).dig("response", "body", "string")
  end
end
