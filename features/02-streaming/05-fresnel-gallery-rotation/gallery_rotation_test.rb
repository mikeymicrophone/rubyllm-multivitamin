# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "gallery_rotation"

class GalleryRotationTest < Minitest::Test
  def test_empty_and_reasoning_chunks_are_kept_off_the_gallery_phone
    result = nil
    Multivitamin::Cassettes.play(__dir__, "gallery_rotation") do
      result = FresnelGalleryRotation::GalleryRotation.conduct
    end

    assert_includes result.speech, "0.4"
    assert_includes result.speech, "9.6"
    assert_equal result.speech, result.spoken_pieces.join
    assert_operator result.reasoning_chunks, :>, 0
    assert_operator result.empty_chunks, :>, result.reasoning_chunks
    assert_operator result.thinking.to_s.length, :>, 0

    assert_nil result.clipped_content
    assert_equal "", result.clipped_spoken_pieces.join
    assert_equal true, result.clipped_max_tokens
    assert_equal :max_tokens, result.clipped_finish
    assert_operator result.clipped_reasoning_chunks, :>, 0
    assert_includes result.clipped_thinking, "0.4"
    assert_includes result.clipped_thinking, "Fresnel"
  end

  def test_the_clipped_stream_sends_the_output_cap
    cassette = YAML.load_file(File.expand_path("cassettes/gallery_rotation.yml", __dir__))
    interactions = cassette.fetch("http_interactions")
    open_request = interactions[0].dig("request", "body", "string")
    clipped_request = interactions[1].dig("request", "body", "string")
    clipped_response = interactions[1].dig("response", "body", "string")
    clipped_response = clipped_response.dup.force_encoding("UTF-8")

    refute_includes open_request, "max_tokens"
    assert_includes clipped_request, '"max_tokens":64'
    assert_includes clipped_response, '"finish_reason":"length"'
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/gallery_rotation.yml", __dir__))

    refute_match(/sk-or-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
