# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "rejected_key"

class DohaFalconMewsRejectedKeyTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/rejected_key.yml", __dir__)

  def test_the_rejected_key_is_unauthorized_and_the_shape_omits_the_ledger
    result = nil
    Multivitamin::Cassettes.play(__dir__, "rejected_key") do
      result = DohaFalconMews::RejectedKey.conduct
    end

    assert_instance_of RubyLLM::UnauthorizedError, result.error
    assert result.is_llm_error
    assert_equal 401, result.status
    assert_kind_of RubyLLM::RequestShape, result.shape
    assert_equal %i[
      provider model step payload_keys thinking_settings instructions
      turn_count omitted_turns turns tool_names tool_rounds problems
    ], result.shape_hash.keys
    refute_includes result.shape.to_s, "0.92"
    refute_includes result.shape.to_s, "Najma"
    refute_includes result.shape.to_s, DohaFalconMews::RejectedKey::LEDGER_QUESTION
    assert_equal 401, interactions.fetch(0).dig("response", "status", "code")
  end

  def test_cassette_does_not_carry_a_live_or_rejected_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
    refute_includes cassette, DohaFalconMews::RejectedKey::REJECTED
  end

  def interactions
    YAML.load_file(CASSETTE).fetch("http_interactions")
  end
end
