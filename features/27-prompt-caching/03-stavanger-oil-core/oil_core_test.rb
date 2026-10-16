# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "oil_core"

class StavangerOilCoreBreakpointTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/oil_core.yml", __dir__)

  def test_the_breakpoint_is_on_the_instructions
    result = nil
    Multivitamin::Cassettes.play(__dir__, "oil_core") do
      result = StavangerOilCore::OilCore.conduct
    end

    assert_instance_of RubyLLM::BadRequestError, result.error
    assert_match(/prompt_cache_breakpoint is not supported/i, result.error.message)
    assert_includes request_body, "prompt_cache_breakpoint"
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
