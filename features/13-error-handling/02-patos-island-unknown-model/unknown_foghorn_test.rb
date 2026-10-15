# frozen_string_literal: true

require "minitest/autorun"
require_relative "unknown_foghorn"

class PatosIslandUnknownFoghornTest < Minitest::Test
  def test_the_unlisted_foghorn_is_model_not_found
    result = nil
    Multivitamin::Cassettes.play(__dir__, "unknown_foghorn") do
      result = PatosIslandUnknownModel::UnknownFoghorn.conduct
    end

    assert_equal "RubyLLM::ModelNotFoundError", result.error_class
    assert_equal "StandardError", result.superclass
    refute result.caught_as_provider_error
    assert_includes result.message, PatosIslandUnknownModel::UnknownFoghorn::DROPPED
    assert_includes result.message, "RubyLLM.models.refresh"
  end
end
