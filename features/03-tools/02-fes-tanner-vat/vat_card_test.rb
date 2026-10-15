# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "vat_card"

class VatCardTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/vat_card.yml", __dir__)

  def test_the_clerk_reads_the_chouara_vat
    result = nil
    Multivitamin::Cassettes.play(__dir__, "vat_card") do
      result = FesTannerVat::VatLookup.conduct
    end

    assert_equal FesTannerVat::VatCard::VATS.fetch("chouara"), result.tool_content
    assert_includes result.answer, "FEZ-4"
    assert_equal %i[system user assistant tool assistant], result.roles
    assert_kind_of Hash, result.arguments
    assert_match(/chouara/i, result.arguments.fetch("vat"))

    request = YAML.load_file(CASSETTE).dig("http_interactions", 0, "request", "body", "string")
    assert_includes request, '"vat":{"type":"string"}'
    assert_includes request, '"required":["vat"]'
    refute_includes request, "FEZ-4"
  end

  def test_the_vat_keyword_is_inferred_and_a_bad_call_returns_an_error_hash
    tool = FesTannerVat::VatCard.new
    schema = tool.parameters_schema

    assert_equal "string", schema.dig("properties", "vat", "type")
    assert_nil schema.dig("properties", "vat", "description")
    assert_equal ["vat"], schema.fetch("required")
    assert_equal true, schema.fetch("strict")

    missing = tool.call
    unknown = tool.call(vat: "chouara", shelf: "upper")

    assert_equal({ error: "Invalid tool arguments: missing keyword: vat" }, missing)
    assert_equal({ error: "Invalid tool arguments: unknown keyword: shelf" }, unknown)
    assert_includes tool.execute(vat: "Chouara"), "FEZ-4"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
    refute_includes cassette, "Bearer sk-"
  end
end
