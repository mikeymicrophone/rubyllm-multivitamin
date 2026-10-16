# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "reserve_slip"

class ReserveTaskTypeTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/reserve_slip.yml", __dir__)

  def test_openai_omits_task_type_and_the_two_vectors_agree
    result = nil
    Multivitamin::Cassettes.play(__dir__, "reserve_slip") do
      result = HelsinkiReserveSlip::ReserveSlip.conduct
    end

    assert_equal "text-embedding-3-small", result.model_id
    assert_equal 1536, result.query_vector.length
    assert_equal result.query_vector.length, result.document_vector.length
    assert_in_delta 1.0, result.score, 0.0001
    assert_operator result.query_tokens, :>, 0
    assert_operator result.cost, :>, 0

    request_bodies.each do |body|
      assert_includes body, '"model":"text-embedding-3-small"'
      assert_includes body, "slip B4"
      refute_includes body, "task_type"
      refute_includes body, "input_type"
      refute_includes body, "RETRIEVAL_QUERY"
      refute_includes body, "RETRIEVAL_DOCUMENT"
      refute_includes body, '"title"'
    end
    assert_equal 2, YAML.load_file(CASSETTE).fetch("http_interactions").length
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
