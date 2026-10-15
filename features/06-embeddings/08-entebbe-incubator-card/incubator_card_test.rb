# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "incubator_card"

class IncubatorCardEmbedTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/incubator_card.yml", __dir__)

  def test_the_plaque_embeds_on_gemini
    result = nil
    Multivitamin::Cassettes.play(__dir__, "incubator_card") do
      result = EntebbeIncubatorCard::IncubatorCard.conduct
    end

    assert_equal 768, result.vectors.length
    assert_kind_of Float, result.vectors.fetch(0)
    assert_equal "google/gemini-embedding-2", result.model_id
    assert_operator result.input_tokens, :>, 0

    request = request_bodies.fetch(0)
    assert_includes request, '"model":"google/gemini-embedding-2"'
    assert_includes request, '"dimensions":768'
    assert_includes request, '"type":"image_url"'
    assert_includes request, "data:image/png;base64,"
    assert_includes request, "Entebbe UVRI incubator plaque"
    assert_equal 1, YAML.load_file(CASSETTE).fetch("http_interactions").length
  end

  def test_openai_refuses_the_png_before_http
    Multivitamin::Cassettes.prepare_key!
    EntebbeIncubatorCard::IncubatorCard.configure_openai

    error = assert_raises(RubyLLM::UnsupportedAttachmentError) do
      RubyLLM.embed(
        EntebbeIncubatorCard::IncubatorCard::CAPTION,
        model: Multivitamin::Models::OPENAI_EMBEDDING,
        provider: :openai,
        with: EntebbeIncubatorCard::IncubatorCard::PLAQUE
      )
    end

    assert_match(%r{Unsupported attachment type: image/png}, error.message)
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
    refute_includes cassette, "Bearer sk-"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map do |interaction|
      interaction.dig("request", "body", "string").to_s.dup.force_encoding(Encoding::UTF_8)
    end
  end
end
