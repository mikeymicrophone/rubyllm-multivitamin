# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "yaml"
require_relative "glaze_ticket"

class IznikGlazeTicketTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/glaze_ticket.yml", __dir__)

  def test_descriptions_drop_the_crossed_out_glaze_and_the_predicate_is_yes
    result = nil
    Multivitamin::Cassettes.play(__dir__, "glaze_ticket") do
      result = IznikGlazeTicket::HandwrittenTicket.conduct
    end

    assert_includes result.parsed["kiln"], "Çini 4"
    assert_match(/iznik red|red/i, result.parsed["glaze"])
    refute_includes result.parsed["glaze"].downcase, "cobalt"
    assert_in_delta 14.5, result.parsed["bowls"], 0.001
    assert_equal "Hatice", result.parsed["due_for"]
    assert_operator result.probability, :>=, 0.9
    assert_operator result.cost, :>, 0

    schema = JSON.parse(request_bodies.fetch(0)).dig("text", "format", "schema")
    assert_includes schema.dig("properties", "glaze", "description"), "crossed out"
    assert_includes schema.dig("properties", "due_for", "description"), "crossed out"

    decision = JSON.parse(request_bodies.fetch(1))
    assert_equal "https://api.openai.com/v1/decisions", request_uris.fetch(1)
    assert_equal "gpt-6-luna", decision["model"]
    question = decision["questions"].fetch(0)
    assert_equal "predicate", question["type"]
    assert_equal "kiln_before_friday", question["name"]
    refute decision.key?("text")
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    interactions.map { |hit| hit.dig("request", "body", "string") }
  end

  def request_uris
    interactions.map { |hit| hit.dig("request", "uri") }
  end

  def interactions
    YAML.load_file(CASSETTE).fetch("http_interactions")
  end
end
