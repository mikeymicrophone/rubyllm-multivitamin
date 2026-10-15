# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "corridor_check"

class CorridorCheckTest < Minitest::Test
  def test_token_counts_arrive_on_the_last_chunk
    result = nil
    Multivitamin::Cassettes.play(__dir__, "corridor_check") do
      result = KigaliCorridorCheck::CorridorCheck.conduct
    end

    assert_includes result.speech, "Amahoro"
    assert_includes result.speech, "66"
    assert_operator result.notes.size, :>, 1

    usage = result.notes.select { |note| note.input_tokens }
    assert_equal [result.notes.last], usage
    assert_equal result.input_tokens, usage.last.input_tokens
    assert_equal result.output_tokens, usage.last.output_tokens
    assert_equal result.thinking_tokens, usage.last.thinking_tokens
    assert_equal result.finish_reason, usage.last.finish_reason
    assert_operator result.input_tokens, :>, 0
    assert_operator result.output_tokens, :>, 0
    assert_operator result.thinking_tokens, :>, 0
    assert_equal 0, result.cost

    finished_early = result.notes[0..-2].select(&:finish_reason)
    assert_operator finished_early.size, :>=, 1
    assert finished_early.all? { |note| note.input_tokens.nil? }
  end

  def test_the_stream_asks_for_usage
    cassette = YAML.load_file(File.expand_path("cassettes/corridor_check.yml", __dir__))
    request = cassette.dig("http_interactions", 0, "request", "body", "string")

    assert_includes request, '"stream":true'
    assert_includes request, '"include_usage":true'
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/corridor_check.yml", __dir__))

    refute_match(/sk-(?:or-v1-)?[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
