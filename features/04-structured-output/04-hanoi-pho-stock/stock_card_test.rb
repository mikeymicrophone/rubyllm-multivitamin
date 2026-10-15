# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "yaml"
require_relative "stock_card"

class PhoStockCardTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/stock_card.yml", __dir__)

  def test_stock_vessel_and_temperatures_are_nested_objects
    result = nil
    Multivitamin::Cassettes.play(__dir__, "stock_card") do
      result = HanoiPhoStock::MorningStock.conduct
    end

    stock = result.parsed.fetch("stock")
    vessel = result.parsed.fetch("vessel")
    temperatures = result.parsed.fetch("temperatures")
    assert_equal "3", stock["kettle"]
    assert_equal "oxtail", stock["bones"]
    assert_equal 90, stock["minutes"]
    assert_equal "Stockpot No. 2", vessel["name"]
    assert_equal "north house", vessel["house"]
    assert_equal 85, temperatures["come_up_c"]
    assert_equal 95, temperatures["simmer_c"]
    assert_kind_of Integer, temperatures["simmer_c"]
    assert_equal %i[system user assistant], result.roles
    assert_operator result.cost, :>, 0

    schema = JSON.parse(request_bodies.fetch(0)).dig("text", "format", "schema")
    assert_equal "object", schema.dig("properties", "stock", "type")
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
