# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "lens_defects"

class LensDefectBatchTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/lens_defects.yml", __dir__)

  def test_four_cabinet_notes_come_back_as_four_vectors
    result = nil
    Multivitamin::Cassettes.play(__dir__, "lens_defects") do
      result = NewDungenessLensDefects::LensDefects.conduct
    end

    notes = NewDungenessLensDefects::LensDefects::NOTES
    assert_equal notes.length, result.vectors.length
    result.vectors.each do |vector|
      assert_equal 1536, vector.length
      assert_kind_of Float, vector.fetch(0)
    end
    assert_equal "text-embedding-3-small", result.model_id
    assert_operator result.input_tokens, :>, 0
    assert_operator result.cost, :>, 0

    request = request_bodies.fetch(0)
    assert_includes request, '"input":['
    assert_includes request, "catalog NP-4"
    assert_includes request, "catalog CW-2"
    assert_equal 1, YAML.load_file(CASSETTE).fetch("http_interactions").length
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map do |interaction|
      interaction.dig("request", "body", "string").to_s
    end
  end
end
