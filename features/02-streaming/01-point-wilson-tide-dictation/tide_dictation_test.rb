# frozen_string_literal: true

require "minitest/autorun"
require_relative "tide_dictation"

class TideDictationTest < Minitest::Test
  def test_the_block_hears_chunks_and_the_message_is_their_join
    result = nil
    Multivitamin::Cassettes.play(__dir__, "tide_dictation") do
      result = PointWilsonTideDictation::TideDictation.conduct
    end

    assert_includes result.speech, "Alden"
    assert_includes result.speech, "10:46"
    assert_match(/10:46/, result.speech)
    assert result.notes.all?(&:chunk)
    assert_operator result.notes.size, :>, 1

    assert result.notes.all? { |note| note.content.is_a?(String) }
    assert_equal result.speech, result.notes.map { |note| note.content.to_s }.join
    assert_equal result.thinking, result.notes.filter_map(&:thinking).join

    reasoning = result.notes.select { |note| note.content.empty? && note.thinking }
    assert_operator reasoning.size, :>, 0
    assert_operator result.notes.count { |note| !note.content.empty? }, :>, 0

    assert result.notes.all? { |note| note.model_id == result.model_id }
    assert_includes result.model_id, "nemotron-3-super-120b-a12b"

    usage = result.notes.select { |note| note.input_tokens }
    assert_equal [result.notes.last], usage
    assert_equal result.input_tokens, usage.last.input_tokens
    assert_equal result.output_tokens, usage.last.output_tokens
    assert_equal result.thinking_tokens, usage.last.thinking_tokens
    assert_operator result.input_tokens, :>, 0
    assert_operator result.output_tokens, :>, 0
    assert_operator result.thinking_tokens, :>, 0
    assert_equal result.finish_reason, usage.last.finish_reason
    assert_equal :stop, result.finish_reason
    assert_equal %i[system user assistant], result.roles
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/tide_dictation.yml", __dir__))

    refute_match(/sk-or-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
