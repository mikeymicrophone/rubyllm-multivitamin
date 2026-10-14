# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "lens_drawers"

class LensDrawersTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/lens_drawers.yml", __dir__)

  def test_each_drawer_is_an_object_in_the_array
    result = nil
    Multivitamin::Cassettes.play(__dir__, "lens_drawers") do
      result = NewDungenessLensDrawers::DrawerInventory.conduct
    end

    drawers = result.parsed.fetch("drawers")
    assert_kind_of Array, drawers
    assert_equal 3, drawers.size
    assert drawers.all? { |drawer| drawer.is_a?(Hash) }
    by_letter = drawers.to_h { |drawer| [drawer["drawer"], drawer] }
    assert_equal "bull's-eye panel", by_letter["A"]["contents"]
    assert_equal 2, by_letter["A"]["spares"]
    assert_equal "catadioptric prism", by_letter["B"]["contents"]
    assert_equal 1, by_letter["B"]["spares"]
    assert_equal "clockwork wick", by_letter["C"]["contents"]
    assert_equal 6, by_letter["C"]["spares"]
    assert by_letter.values.all? { |drawer| drawer["spares"].is_a?(Integer) }
    assert_equal %i[system user assistant], result.roles
    assert_equal :stop, result.finish
    assert_operator result.cost, :>, 0

    schema = JSON.parse(request_bodies.fetch(0)).dig("text", "format", "schema")
    assert_equal "array", schema.dig("properties", "drawers", "type")
    assert_equal "object", schema.dig("properties", "drawers", "items", "type")
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
