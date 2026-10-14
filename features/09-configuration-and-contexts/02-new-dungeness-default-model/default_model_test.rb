# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "default_model"

class DungenessDefaultModelTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/default_model.yml", __dir__)

  def test_the_unnamed_chat_uses_default_model_and_the_named_chat_does_not
    result = nil
    Multivitamin::Cassettes.play(__dir__, "default_model") do
      result = NewDungenessDefaultModel::DefaultModel.conduct
    end

    assert_includes result.default_reply, "NB-17"
    assert_includes result.named_reply, "NB-17"
    assert_match(/drawer[[:space:]]B/i, result.default_reply)
    assert_equal result.configured_default, result.default_model_id
    assert_equal result.named_slug, result.named_model_id
    refute_equal result.default_model_id, result.named_model_id

    bodies = request_bodies
    assert_includes bodies.fetch(0), "\"model\":\"#{result.configured_default}\""
    assert_includes bodies.fetch(1), "\"model\":\"#{result.named_slug}\""
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map do |interaction|
      interaction.dig("request", "body", "string").to_s
    end
  end
end
