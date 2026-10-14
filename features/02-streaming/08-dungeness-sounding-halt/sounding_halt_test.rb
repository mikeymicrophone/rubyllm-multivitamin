# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "yaml"
require_relative "sounding_halt"

class SoundingHaltTest < Minitest::Test
  def test_the_mate_stops_the_cast_after_two_spoken_pieces
    result = nil
    Multivitamin::Cassettes.play(__dir__, "sounding_halt") do
      result = DungenessSoundingHalt::SoundingHalt.conduct
    end

    assert_instance_of RubyLLM::CancelledError, result.error
    assert_kind_of StandardError, result.error
    refute_kind_of RubyLLM::Error, result.error
    assert_equal "Chat generation cancelled", result.error.message
    assert_equal 2, result.spoken.size
    assert_equal %i[system user], result.roles

    full = spoken_deltas(stream_body)
    assert_operator full.size, :>, result.spoken.size
    assert_equal result.spoken, full.first(2)
    refute_equal full.join, result.spoken.join
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/sounding_halt.yml", __dir__))

    refute_match(/sk-or-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end

  def stream_body
    loaded = YAML.load_file(File.expand_path("cassettes/sounding_halt.yml", __dir__))
    loaded.dig("http_interactions", 0, "response", "body", "string").dup.force_encoding("UTF-8")
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
