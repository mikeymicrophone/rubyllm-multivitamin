# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "slip_blob"

class PortTownsendSlipBlobTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/slip_blob.yml", __dir__)
  PNG_MAGIC = "\x89PNG\r\n\x1A\n".b

  def test_to_blob_matches_the_saved_file
    result = nil
    Multivitamin::Cassettes.play(__dir__, "slip_blob") do
      result = PortTownsendSlipBlob::SlipBlob.conduct
    end

    assert_equal result.blob, result.file_bytes
    assert_equal PNG_MAGIC, result.magic
    assert_includes request_body, "Khutzeymateen"
    assert_includes request_body, "SE 25"
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
