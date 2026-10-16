# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "paprika_overflow"

class SzegedPaprikaMillOverflowTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/paprika_overflow.yml", __dir__)

  def test_the_pasted_dryer_log_exceeds_the_embedding_window
    result = nil
    Multivitamin::Cassettes.play(__dir__, "paprika_overflow") do
      result = SzegedPaprikaMill::PaprikaOverflow.conduct
    end

    assert_instance_of RubyLLM::ContextLengthExceededError, result.error
    assert result.is_llm_error
    assert_equal 400, result.status
    assert_match(/8192|context length/i, result.message)
    assert_nil result.shape
    assert_equal 1, interactions.length
    assert_equal 400, interactions.fetch(0).dig("response", "status", "code")
    assert_includes interactions.fetch(0).dig("request", "body", "string"), "Szeged"
    refute_includes RubyLLM::Transport::Connection.send(:retry_exceptions), RubyLLM::ContextLengthExceededError
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def interactions
    YAML.load_file(CASSETTE).fetch("http_interactions")
  end
end
