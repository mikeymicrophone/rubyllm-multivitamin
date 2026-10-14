# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "yaml"
require_relative "cook_card"

class RetortCookCardTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/cook_card.yml", __dir__)

  def test_cook_vessel_and_temperatures_are_nested_objects
    result = nil
    Multivitamin::Cassettes.play(__dir__, "cook_card") do
      result = AnacortesRetortCard::MorningCook.conduct
    end

    cook = result.parsed.fetch("cook")
    vessel = result.parsed.fetch("vessel")
    temperatures = result.parsed.fetch("temperatures")
    assert_equal "3", cook["basket"]
    assert_equal "sockeye", cook["product"]
    assert_equal 90, cook["minutes"]
    assert_equal "Retort No. 2", vessel["name"]
    assert_equal "north house", vessel["house"]
    assert_equal 230, temperatures["come_up_f"]
    assert_equal 250, temperatures["process_f"]
    assert_kind_of Integer, temperatures["process_f"]
    assert_equal %i[system user assistant], result.roles
    assert_operator result.cost, :>, 0

    schema = JSON.parse(request_bodies.fetch(0)).dig("text", "format", "schema")
    assert_equal "object", schema.dig("properties", "cook", "type")
    assert_equal "object", schema.dig("properties", "temperatures", "type")
    assert_includes schema["required"], "vessel"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map { |hit| hit.dig("request", "body", "string") }
  end
end
