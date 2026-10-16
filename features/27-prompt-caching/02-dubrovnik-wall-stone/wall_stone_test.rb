# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "wall_stone"

class DubrovnikWallStoneTtlTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/wall_stone.yml", __dir__)

  def test_the_two_ttls_are_on_the_wire
    result = nil
    Multivitamin::Cassettes.play(__dir__, "wall_stone") do
      result = DubrovnikWallStone::WallStone.conduct
    end

    assert_instance_of RubyLLM::BadRequestError, result.hour_error
    assert_instance_of RubyLLM::BadRequestError, result.half_error
    assert_match(/Invalid value: '1h'/, result.hour_error.message)
    assert_match(/30m/, result.hour_error.message)
    assert_match(/prompt_cache_options is not supported/i, result.half_error.message)
    assert_equal 2, interactions.length
    assert_includes request_body(0), '"ttl":"1h"'
    assert_includes request_body(1), '"ttl":"30m"'
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def interactions
    YAML.load_file(CASSETTE).fetch("http_interactions")
  end

  def request_body(index)
    interactions.fetch(index).dig("request", "body", "string").to_s
  end
end
