# frozen_string_literal: true

require "minitest/autorun"
require_relative "furnace_cancel"

class PersistedAntofagastaFurnaceCancelTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/furnace_cancel.yml", __dir__)

  def test_cancel_clears_the_blank_assistant_row
    result = nil
    Multivitamin::Cassettes.play(__dir__, "furnace_cancel") do
      result = AntofagastaFurnaceCancel::FurnaceClerk.conduct
    end

    assert_equal 2, result.spoken.size
    assert_equal RubyLLM::CancelledError, result.error_class
    assert_equal StandardError, result.error_parent
    refute_operator RubyLLM::CancelledError, :<, RubyLLM::Error
    assert result.cancelled_during
    assert_equal %i[system user], result.roles
    assert_equal 0, result.assistant_count
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-(?:or-v1-)?[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
