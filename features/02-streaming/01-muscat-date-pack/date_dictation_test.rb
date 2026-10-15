# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "date_dictation"

class DateDictationTest < Minitest::Test
  def test_the_block_hears_chunks_and_the_message_is_their_join
    result = nil
    Multivitamin::Cassettes.play(__dir__, "date_dictation") do
      result = MuscatDatePack::DateDictation.conduct
    end

    assert_includes result.speech, "Zahra"
    assert_includes result.speech, "10:46"
    assert_match(/0\.4[[:space:]]kg/, result.speech)
    assert_match(/8\.1[[:space:]]kg/, result.speech)
    assert result.notes.all?(&:chunk)
    assert_operator result.notes.size, :>, 1

    assert result.notes.all? { |note| note.content.nil? || note.content.is_a?(String) }
    assert_equal result.speech, result.notes.map { |note| note.content.to_s }.join
    assert_equal result.thinking.to_s, result.notes.filter_map(&:thinking).join

    spoken = result.notes.reject { |note| note.content.to_s.empty? }
    assert_operator spoken.size, :>, 0
    reasoning = result.notes.select { |note| note.content.to_s.empty? && note.thinking }
    # gpt-4.1-mini may not stream reasoning. When it does, empty content is
    # still truthy, so the join of every content still equals the message.
    assert_equal result.speech, spoken.map(&:content).join if reasoning.empty?

    models = result.notes.map(&:model_id).compact.uniq
    assert_equal [result.model_id], models
    assert_includes result.model_id, Multivitamin::Models::OPENAI_CHAT

    usage = result.notes.select { |note| note.input_tokens }
    assert_equal [result.notes.last], usage
    assert_equal result.input_tokens, usage.last.input_tokens
    assert_equal result.output_tokens, usage.last.output_tokens
    assert_equal result.thinking_tokens, usage.last.thinking_tokens
    assert_operator result.input_tokens, :>, 0
    assert_operator result.output_tokens, :>, 0
    assert_operator result.thinking_tokens, :>=, 0
    assert_equal result.finish_reason, usage.last.finish_reason
    assert_equal :stop, result.finish_reason
    assert_equal %i[system user assistant], result.roles
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(File.expand_path("cassettes/date_dictation.yml", __dir__))

    refute_match(/sk-(?:or-v1-)?[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def test_the_sse_body_is_readable_after_yaml_load
    raw = File.binread(File.expand_path("cassettes/date_dictation.yml", __dir__))
    loaded = YAML.load_file(File.expand_path("cassettes/date_dictation.yml", __dir__))
    body = loaded.dig("http_interactions", 0, "response", "body", "string").dup.force_encoding("UTF-8")

    assert_includes body, "data:"
    assert_includes body, "response.output_text.delta"
    if raw.include?("!binary")
      refute_includes raw, "data:"
    else
      assert_includes raw, "data:"
    end
    if body.include?("\u202f")
      assert_includes body, "0.4\u202f"
      refute_includes body, "0.4\u202fkg"
    end
  end
end
