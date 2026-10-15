# frozen_string_literal: true

require "minitest/autorun"
require_relative "estuary_latch"

class EstuaryLatchTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/estuary_latch.yml", __dir__)

  def test_a_second_ask_raises_until_the_gate_is_approved
    result = nil
    Multivitamin::Cassettes.play(__dir__, "estuary_latch") do
      result = SkokomishPendingAsk::RiverTender.conduct
    end

    assert_equal "RubyLLM::PendingToolCallsError", result.error_class
    assert_equal "StandardError", result.error_superclass
    refute result.caught_as_provider_error
    assert_includes result.error_message, "estuary_latch"
    assert_includes result.error_message, "approve or deny"
    assert result.opened
    assert_includes result.answer, "2.2"
    assert_includes result.answer, "101"
    assert_equal %i[system user assistant tool assistant], result.roles
    refute RubyLLM::PendingToolCallsError.ancestors.include?(RubyLLM::Error)
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
