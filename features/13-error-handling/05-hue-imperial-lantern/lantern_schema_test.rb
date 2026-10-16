# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "yaml"
require_relative "lantern_schema"

class HueImperialLanternRequestShapeTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/lantern_schema.yml", __dir__)

  def test_the_broken_count_is_a_bad_request_and_the_shape_omits_the_card
    result = nil
    Multivitamin::Cassettes.play(__dir__, "lantern_schema") do
      result = HueImperialLantern::LanternSchema.conduct
    end

    assert_instance_of RubyLLM::BadRequestError, result.error
    assert_equal 400, result.status
    assert_includes result.message, "LanternCount"
    assert_includes result.message, "spare_wicks"
    assert_kind_of RubyLLM::RequestShape, result.shape
    assert_equal %i[
      provider model step payload_keys thinking_settings instructions
      turn_count omitted_turns turns tool_names tool_rounds problems
    ], result.shape_hash.keys
    assert_equal "openai", result.shape_hash[:provider]
    assert_equal "gpt-4.1-mini", result.shape_hash[:model]
    refute_includes result.shape_text, "186"
    refute_includes result.shape_text, "Gia Hoi"
    refute_includes result.shape_text, "silk-frame"
    refute_includes JSON.generate(result.shape_hash), "186"

    request = JSON.parse(interactions.fetch(0).dig("request", "body", "string"))
    assert_equal true, request.dig("text", "format", "strict")
    refute_includes request.dig("text", "format", "schema", "required"), "spare_wicks"
    assert_equal 400, interactions.fetch(0).dig("response", "status", "code")
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def interactions
    YAML.load_file(CASSETTE).fetch("http_interactions")
  end
end
