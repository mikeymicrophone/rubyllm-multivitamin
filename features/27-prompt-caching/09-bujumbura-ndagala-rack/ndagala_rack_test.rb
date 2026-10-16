# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "ndagala_rack"

class BujumburaNdagalaRackImplicitTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/ndagala_rack.yml", __dir__)

  def test_the_keyword_breakpoint_and_implicit_mode_are_on_the_wire
    result = nil
    Multivitamin::Cassettes.play(__dir__, "ndagala_rack") do
      result = BujumburaNdagalaRack::NdagalaRack.conduct
    end

    assert_includes result.brief, "Aline"
    assert_includes result.brief, "05:55"
    assert_includes request_body, "prompt_cache_breakpoint"
    assert_includes request_body, '"mode":"implicit"'
    assert_includes request_body, '"ttl":"1h"'
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_body
    YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0).dig("request", "body", "string").to_s
  end
end
