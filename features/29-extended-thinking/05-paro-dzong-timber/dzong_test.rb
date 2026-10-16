# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "dzong"

class ParoDzongOmittedDisplayTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/dzong.yml", __dir__)

  def test_omitted_display_leaves_thinking_text_blank
    result = nil
    Multivitamin::Cassettes.play(__dir__, "dzong") do
      result = ParoDzongTimber::DzongTimber.conduct
    end

    assert_includes result.brief, "Tashi"
    assert_includes result.brief, "06:50"
    assert_equal :omitted, result.display[:display]
    assert_nil result.thinking_text
    refute_includes request_body, '"summary":"auto"'
    assert_includes request_body, '"effort":"low"'
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
