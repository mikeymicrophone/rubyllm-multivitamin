# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "stela_embed"

class CopanStelaEmbedTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/stela_embed.yml", __dir__)

  def test_ctx_embed_uses_the_context_key_and_ruby_llm_embed_uses_the_global_key
    result = nil
    Multivitamin::Cassettes.play(__dir__, "stela_embed") do
      result = CopanStelaEmbed::StelaEmbed.conduct
    end

    assert_operator result.context_width, :>, 0
    assert_operator result.global_width, :>, 0
    assert_equal "Copán epigraphy desk", result.context_title
    assert_equal "RubyLLM Multivitamin", result.global_title
    refute_equal result.context_model, result.global_model

    interactions = YAML.load_file(CASSETTE).fetch("http_interactions")
    uris = interactions.map { |interaction| interaction.dig("request", "uri") }
    auths = interactions.map { |interaction| Array(interaction.dig("request", "headers", "Authorization")).join }

    assert uris.any? { |uri| uri.include?("openrouter.ai") }
    assert uris.any? { |uri| uri.include?("api.openai.com") }
    assert auths.any? { |auth| auth.include?("<OPENROUTER_API_KEY>") }
    assert auths.any? { |auth| auth.include?("<OPENAI_API_KEY>") }
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
