# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "mccurdy_blob"

class McCurdyPointSaveVsBlobTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/mccurdy_blob.yml", __dir__)

  def test_to_blob_matches_the_saved_file
    result = nil
    Multivitamin::Cassettes.play(__dir__, "mccurdy_blob") do
      result = McCurdyPointSaveBlob::McCurdyBlob.conduct
    end

    assert_equal result.blob, result.file_bytes
    assert_equal 0xFF, result.magic
    assert_match(/kelp_ledge\.mp3\z/, result.returned_path)
    assert_includes request_body, "McCurdy Point"
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
