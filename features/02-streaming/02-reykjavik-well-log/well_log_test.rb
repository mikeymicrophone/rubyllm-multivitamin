# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "stringio"
require "yaml"
require_relative "well_log"

class WellLogTest < Minitest::Test
  def test_the_log_prints_each_chunk_and_the_replay_matches
    well_log = StringIO.new
    result = nil
    Multivitamin::Cassettes.play(__dir__, "well_log") do
      result = ReykjavikWellLog::WellLog.conduct(well_log)
    end

    assert_includes result.speech, "2"
    assert_includes result.speech, "18"
    assert_operator result.pieces.size, :>, 1
    assert_equal result.speech, result.pieces.join
    assert_equal 0, result.thinking_chunks
    assert_equal result.speech, well_log.string

    body = stream_bodies.fetch(0)
    assert_includes body, "data:"
    assert_includes body, "data: [DONE]"
    assert_equal result.pieces, spoken_deltas(body)

    # A second play reads the same SSE body. The live model is not asked again:
    # two recordings of this card were not the same words.
    return if ENV["LIVE"] == "1"

    replay_log = StringIO.new
    replay = nil
    Multivitamin::Cassettes.play(__dir__, "well_log") do
      replay = ReykjavikWellLog::WellLog.conduct(replay_log)
    end

    assert_equal result.pieces, replay.pieces
    assert_equal result.speech, replay.speech
  end

  def test_the_cassette_records_an_sse_stream
    cassette = YAML.load_file(File.expand_path("cassettes/well_log.yml", __dir__))
    interactions = cassette.fetch("http_interactions")

    assert_equal 1, interactions.size
    interactions.each do |interaction|
      request = interaction.dig("request", "body", "string")
      assert_includes request, '"stream":true'
      assert_includes request, '"include_usage":true'
      assert_includes request, '"reasoning":{"enabled":false}'
      content_type = interaction.dig("response", "headers", "Content-Type")
      assert_includes Array(content_type), "text/event-stream"
    end
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/well_log.yml", __dir__))

    refute_match(/sk-(?:or-v1-)?[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end

  def stream_bodies
    loaded = YAML.load_file(File.expand_path("cassettes/well_log.yml", __dir__))
    loaded.fetch("http_interactions").map do |interaction|
      interaction.dig("response", "body", "string").dup.force_encoding("UTF-8")
    end
  end

  def spoken_deltas(body)
    body.split("\n").filter_map do |line|
      next unless line.start_with?("data:")

      payload = line.delete_prefix("data:").strip
      next if payload == "[DONE]"

      content = JSON.parse(payload).dig("choices", 0, "delta", "content").to_s
      content unless content.empty?
    end
  end
end
