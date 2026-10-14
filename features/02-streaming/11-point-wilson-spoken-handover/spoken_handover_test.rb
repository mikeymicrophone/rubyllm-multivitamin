# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "yaml"
require_relative "spoken_handover"

class SpokenHandoverTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/spoken_handover.yml", __dir__)

  def test_the_second_stream_still_knows_the_first_brief
    result = nil
    Multivitamin::Cassettes.play(__dir__, "spoken_handover") do
      result = PointWilsonSpokenHandover::SpokenHandover.conduct
    end

    assert_includes result.brief, "07:05"
    assert_match(/horn/i, result.brief)
    assert_equal result.brief, result.brief_pieces.join
    assert_equal result.cabinet, result.cabinet_pieces.join
    assert_operator result.brief_pieces.size, :>, 1
    assert_operator result.cabinet_pieces.size, :>, 1
    assert_match(/do not open the lens cabinet/i, result.cabinet)
    assert_match(/lamp is burning/i, result.cabinet)
    assert_match(/closed/i, result.cabinet)

    assert_equal %i[system user assistant user assistant], result.roles
    assert_equal :stop, result.brief_finish
    assert_equal :stop, result.cabinet_finish
    assert_operator result.cabinet_input_tokens, :>, result.brief_input_tokens

    cassette = YAML.load_file(CASSETTE)
    interactions = cassette.fetch("http_interactions")
    first_request = interactions[0].dig("request", "body", "string")
    second_request = interactions[1].dig("request", "body", "string")

    assert_includes first_request, '"stream":true'
    assert_includes second_request, '"stream":true'
    refute_includes first_request, "reasoning_details"
    refute_includes second_request, "reasoning_details"
    assert_includes interactions[0].dig("response", "body", "string"), "response.output_text.delta"

    replayed = JSON.parse(second_request).fetch("input").find { |item| item["role"] == "assistant" }
    text = replayed.fetch("content").map { |part| part.fetch("text") }.join
    assert_equal result.brief, text
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
    refute_includes cassette, "Bearer sk-"
  end
end
