# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "varnish_cutaway"

class CremonaVarnishCutawaySaveTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/varnish_cutaway.yml", __dir__)
  PNG_MAGIC = "\x89PNG\r\n\x1A\n".b

  def test_save_writes_png_bytes_and_returns_the_path
    result = nil
    Multivitamin::Cassettes.play(__dir__, "varnish_cutaway") do
      result = CremonaVarnishCutaway::VarnishCutaway.conduct
    end

    assert_equal result.path, result.returned_path
    assert_equal PNG_MAGIC, result.magic
    assert_operator result.bytes, :>, 0
    assert_includes request_body, "Cremona"
    assert_equal 1, YAML.load_file(CASSETTE).fetch("http_interactions").length
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_body
    YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0).dig("request", "body", "string")
  end
end
