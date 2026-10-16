# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "medeu_models"

class AlmatyMedeuModelsTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/medeu_models.yml", __dir__)

  def test_mini_and_gpt_image_two_are_named_on_the_wire
    result = nil
    Multivitamin::Cassettes.play(__dir__, "medeu_models") do
      result = AlmatyMedeuModels::MedeuModels.conduct
    end

    assert_equal "gpt-image-1-mini", result.mini.model
    assert_equal "gpt-image-2", result.full.model

    bodies = request_bodies
    assert_equal 2, bodies.length
    assert_includes bodies.fetch(0), '"model":"gpt-image-1-mini"'
    assert_includes bodies.fetch(1), '"model":"gpt-image-2"'
    bodies.each do |body|
      assert_includes body, "Medeu"
      assert_includes body, "12 March 2026"
    end
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map do |interaction|
      interaction.dig("request", "body", "string")
    end
  end
end
