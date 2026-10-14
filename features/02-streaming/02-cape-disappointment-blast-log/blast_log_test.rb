# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "stringio"
require "yaml"
require_relative "blast_log"

class BlastLogTest < Minitest::Test
  def test_the_log_prints_each_chunk_and_the_replay_matches
    horn_log = StringIO.new
    result = nil
    Multivitamin::Cassettes.play(__dir__, "blast_log") do
      result = CapeDisappointmentBlastLog::BlastLog.conduct(horn_log)
    end

    first, second = result.passes
    assert_equal 2, result.passes.size
    assert_includes first.speech, "2"
    assert_includes first.speech, "18"
    assert_operator first.pieces.size, :>, 1
    assert_equal first.speech, first.pieces.join
    assert_equal first.pieces, second.pieces
    assert_equal first.speech, second.speech
    assert_equal 0, first.thinking_chunks
    assert_equal 0, second.thinking_chunks
    assert_equal first.speech + second.speech, horn_log.string

    bodies = stream_bodies
    assert_equal 2, bodies.size
    bodies.each do |body|
      assert_includes body, "data:"
      assert_includes body, "data: [DONE]"
      assert_equal first.pieces, spoken_deltas(body)
    end
  end

  def test_the_cassette_records_an_sse_stream
    cassette = YAML.load_file(File.expand_path("cassettes/blast_log.yml", __dir__))
    interactions = cassette.fetch("http_interactions")

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
    cassette = File.read(File.expand_path("cassettes/blast_log.yml", __dir__))

    refute_match(/sk-or-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end

  def stream_bodies
    loaded = YAML.load_file(File.expand_path("cassettes/blast_log.yml", __dir__))
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
