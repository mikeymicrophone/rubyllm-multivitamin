# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "nadodrze_neon"

class WroclawNadodrzeNeonSplitTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/nadodrze_neon.yml", __dir__)

  def test_openai_omits_the_ttl_split
    result = nil
    Multivitamin::Cassettes.play(__dir__, "nadodrze_neon") do
      result = WroclawNadodrzeNeon::NadodrzeNeon.conduct
    end

    assert_includes result.brief, "Marek"
    assert_includes result.brief, "19:45"
    assert_includes request_body, '"ttl":"1h"'
    assert_nil result.cache_write_by_ttl
    refute_nil result.cache_read
    assert_operator result.input_tokens, :>, 0
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
