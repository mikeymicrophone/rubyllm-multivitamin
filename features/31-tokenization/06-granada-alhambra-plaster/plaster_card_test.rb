# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../support/cassette_assertions"
require_relative "plaster_card"

class GranadaAlhambraPlasterTest < Minitest::Test
  include Multivitamin::CassetteAssertions

  def test_the_nested_repair_schema_is_counted_without_staging_a_turn
    result = play
    bare, structured = requests

    assert_operator result.fetch(:bare), :>, 0
    assert_operator result.fetch(:structured), :>, result.fetch(:bare)
    assert_equal [:system], result.fetch(:roles)
    refute bare.key?("text")
    format = structured.dig("text", "format")
    assert_equal "alhambra_plaster_card", format.fetch("name")
    assert_equal "json_schema", format.fetch("type")
    assert_equal true, format.fetch("strict")
    assert_equal %w[panel area_cm2 hold], format.dig("schema", "properties", "repair", "required")
    assert_equal bare.fetch("input"), structured.fetch("input")
  end

  def test_cassette_has_no_live_key
    assert_cassette_sanitized(__dir__, "plaster_card", key: "OPENAI_API_KEY")
  end

  def play
    Multivitamin::Cassettes.play(__dir__, "plaster_card") { GranadaAlhambraPlaster.conduct }
  end

  def requests = cassette_requests(__dir__, "plaster_card")
  def interactions = cassette_interactions(__dir__, "plaster_card")
end
