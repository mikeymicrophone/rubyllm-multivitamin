# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "yaml"
require_relative "mending_ticket"

class PortAngelesMendingTicketTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/mending_ticket.yml", __dir__)

  def test_descriptions_drop_the_crossed_out_fiber_and_the_predicate_is_yes
    result = nil
    Multivitamin::Cassettes.play(__dir__, "mending_ticket") do
      result = PortAngelesNetTicket::HandwrittenTicket.conduct
    end

    assert_includes result.parsed["boat"], "Kulshan"
    assert_includes result.parsed["twine"].downcase, "tarred nylon"
    refute_includes result.parsed["twine"].downcase, "cotton"
    assert_in_delta 14.5, result.parsed["fathoms"], 0.001
    assert_equal "Alden", result.parsed["due_for"]
    assert_operator result.probability, :>=, 0.9
    assert_operator result.cost, :>, 0

    schema = JSON.parse(request_bodies.fetch(0)).dig("text", "format", "schema")
    assert_includes schema.dig("properties", "twine", "description"), "crossed out"
    assert_includes schema.dig("properties", "due_for", "description"), "crossed out"

    decision = JSON.parse(request_bodies.fetch(1))
    assert_equal "https://api.openai.com/v1/decisions", request_uris.fetch(1)
    assert_equal "gpt-6-luna", decision["model"]
    question = decision["questions"].fetch(0)
    assert_equal "predicate", question["type"]
    assert_equal "loft_before_friday", question["name"]
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
