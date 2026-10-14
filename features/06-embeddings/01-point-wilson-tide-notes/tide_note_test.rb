# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "tide_note"

class TideNoteVectorTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/tide_note.yml", __dir__)

  def test_one_posted_note_becomes_one_flat_vector
    result = nil
    Multivitamin::Cassettes.play(__dir__, "tide_note") do
      result = PointWilsonTideNotes::TideNote.conduct
    end

    assert_kind_of Array, result.vectors
    assert_equal 1536, result.vectors.length
    assert_kind_of Float, result.vectors.fetch(0)
    refute_kind_of Array, result.vectors.fetch(0)
    assert_equal "text-embedding-3-small", result.model_id
    assert_nil result.sparse_vectors
    assert_operator result.input_tokens, :>, 0
    assert_operator result.cost, :>, 0

    request = request_bodies.fetch(0)
    assert_includes request, '"model":"text-embedding-3-small"'
    assert_includes request, "Alden clears the kelp ledge"
    refute_includes request, '"input":['
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
    refute_includes cassette, "Bearer sk-"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map do |interaction|
      interaction.dig("request", "body", "string").to_s
    end
  end
end
