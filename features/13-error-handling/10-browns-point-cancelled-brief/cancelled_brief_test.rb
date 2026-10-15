# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "yaml"
require_relative "cancelled_brief"

class BrownsPointCancelledFogTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/cancelled_brief.yml", __dir__)

  def test_the_clerk_stops_the_brief_after_two_spoken_pieces
    result = nil
    Multivitamin::Cassettes.play(__dir__, "cancelled_brief") do
      result = BrownsPointCancelledBrief::CancelledBrief.conduct
    end

    assert_instance_of RubyLLM::CancelledError, result.error
    refute result.is_llm_error
    assert_equal "Chat generation cancelled", result.error.message
    assert_equal 2, result.spoken.size
    assert_equal %i[system user], result.roles

    full = spoken_deltas(stream_body)
    assert_operator full.size, :>, result.spoken.size
    assert_equal result.spoken, full.first(2)
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def stream_body
    loaded = YAML.load_file(CASSETTE)
    loaded.dig("http_interactions", 0, "response", "body", "string").to_s.dup.force_encoding("UTF-8")
  end

  def spoken_deltas(body)
    body.split("\n").filter_map do |line|
      next unless line.start_with?("data:")

      payload = line.delete_prefix("data:").strip
      next if payload.empty? || payload == "[DONE]"

      event = JSON.parse(payload)
      text = event.dig("delta") || event.dig("text")
      if event["type"] == "response.output_text.delta"
        text = event["delta"]
      end
      text = text.to_s
      text unless text.empty?
    rescue JSON::ParserError
      nil
    end
  end
end
