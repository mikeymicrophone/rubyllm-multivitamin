# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "mystery_stream"

class TranscriptionMysteryBayStreamTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/mystery_stream.yml", __dir__)

  def test_streamed_deltas_rebuild_the_mystery_bay_skiff_tape
    result = nil
    Multivitamin::Cassettes.play(__dir__, "mystery_stream") do
      result = MysteryBayStream::SkiffStream.conduct
    end

    assert_equal Multivitamin::Models::OPENAI_TRANSCRIBE, result.model
    assert_match(/Mystery/i, result.text)
    assert_match(/skiff|oyster/i, result.text)
    assert_operator result.chunks.count(&:delta_flag), :>, 0
    assert result.chunks.any?(&:done_flag)
    assert_equal result.text, result.joined_deltas
    assert_includes result.chunks.fetch(-1).type, "done"

    request = YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0)
    assert_includes request.dig("request", "body", "string"), "stream"
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
