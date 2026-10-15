# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "chimacum_chunks"

class ChimacumStreamedSpeechChunksTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/chimacum_chunks.yml", __dir__)

  def test_chunks_join_to_the_returned_speech
    result = nil
    Multivitamin::Cassettes.play(__dir__, "chimacum_chunks") do
      result = ChimacumStreamedChunks::ChimacumChunks.conduct
    end

    assert_operator result.chunks.length, :>=, 1
    result.chunks.each do |chunk|
      assert_instance_of RubyLLM::SpeechChunk, chunk
      assert_equal "mp3", chunk.format
      assert_equal "audio/mpeg", chunk.mime_type
      assert_equal chunk.data, chunk.to_blob
    end

    assert_equal result.speech.to_blob, result.joined
    assert_equal 0xFF, result.joined.getbyte(0)

    request = request_body
    assert_includes request, "Chimacum"
    assert_includes request, "bridge"
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
