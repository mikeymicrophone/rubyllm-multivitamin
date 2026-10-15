# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "kite_tissue"

class KiteTissueWatercolorTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/kite_tissue.yml", __dir__)

  def test_paint_returns_an_image_of_the_posted_board
    result = nil
    Multivitamin::Cassettes.play(__dir__, "kite_tissue") do
      result = JaipurKiteTissueBoard::KiteTissueWatercolor.conduct
    end

    assert_instance_of RubyLLM::Image, result.image
    assert_equal "gpt-image-1-mini", result.model
    assert_equal "image/png", result.mime_type
    assert result.base64
    assert_includes result.prompt, "Farida"
    assert_includes result.prompt, "JA-17"

    request = request_bodies.fetch(0)
    assert_includes request, '"model":"gpt-image-1-mini"'
    assert_includes request, '"size":"1024x1024"'
    assert_includes request, '"quality":"low"'
    assert_includes request, '"n":1'
    assert_includes request, "Farida"
    assert_equal "https://api.openai.com/v1/images/generations", request_uri
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)

    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_uri
    YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0).dig("request", "uri")
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map do |interaction|
      interaction.dig("request", "body", "string")
    end
  end
end
