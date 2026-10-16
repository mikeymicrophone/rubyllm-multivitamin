# frozen_string_literal: true

require "minitest/autorun"
require_relative "drum_stream"

class PersistedKumasiFontomfromStreamTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/drum_stream.yml", __dir__)

  def test_the_stream_fills_the_empty_assistant_row
    result = nil
    Multivitamin::Cassettes.play(__dir__, "drum_stream") do
      result = KumasiFontomfromStream::DrumStream.conduct
    end

    assert_match(/3|three/i, result.speech)
    assert_includes result.speech, "27"
    assert_equal result.speech, result.saved_content
    assert_equal "", result.blank_before_chunks
    assert_operator result.chunk_count, :>, 0
    assert_equal %i[system user assistant], result.roles
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-(?:or-v1-)?[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
