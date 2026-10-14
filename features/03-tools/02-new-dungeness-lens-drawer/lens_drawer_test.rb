# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "lens_drawer"

class LensDrawerTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/lens_drawer.yml", __dir__)

  def test_the_keeper_reads_the_bullseye_drawer
    result = nil
    Multivitamin::Cassettes.play(__dir__, "lens_drawer") do
      result = NewDungenessLensDrawer::DrawerLookup.conduct
    end

    assert_equal NewDungenessLensDrawer::LensDrawer::DRAWERS.fetch("bullseye"), result.tool_content
    assert_includes result.answer, "ND-4"
    assert_equal %i[system user assistant tool assistant], result.roles
    assert_kind_of Hash, result.arguments
    assert_match(/bullseye/i, result.arguments.fetch("drawer"))

    request = YAML.load_file(CASSETTE).dig("http_interactions", 0, "request", "body", "string")
    assert_includes request, '"drawer":{"type":"string"}'
    assert_includes request, '"required":["drawer"]'
    refute_includes request, "ND-4"
  end

  def test_the_drawer_keyword_is_inferred_and_a_bad_call_returns_an_error_hash
    tool = NewDungenessLensDrawer::LensDrawer.new
    schema = tool.parameters_schema

    assert_equal "string", schema.dig("properties", "drawer", "type")
    assert_nil schema.dig("properties", "drawer", "description")
    assert_equal ["drawer"], schema.fetch("required")
    assert_equal true, schema.fetch("strict")

    missing = tool.call
    unknown = tool.call(drawer: "bullseye", shelf: "upper")

    assert_equal({ error: "Invalid tool arguments: missing keyword: drawer" }, missing)
    assert_equal({ error: "Invalid tool arguments: unknown keyword: shelf" }, unknown)
    assert_includes tool.execute(drawer: "Bullseye"), "ND-4"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
    refute_includes cassette, "Bearer sk-"
  end
end
