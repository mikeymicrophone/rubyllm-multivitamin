# frozen_string_literal: true

require "minitest/autorun"
require_relative "missing_lot"

class SialkotMissingLotTest < Minitest::Test
  def test_a_dropped_lot_is_model_not_found_and_does_not_refresh
    result = nil
    Multivitamin::Cassettes.play(__dir__, "missing_lot") do
      result = SialkotStitch::MissingLot.conduct
    end

    assert_equal "RubyLLM::ModelNotFoundError", result.error_class
    assert_equal "StandardError", result.superclass
    refute result.caught_as_provider_error
    assert_includes result.message, SialkotStitch::MissingLot::DROPPED
    assert_includes result.message, "RubyLLM.models.refresh"
  end
end
