# frozen_string_literal: true

require "minitest/autorun"
require_relative "yatai_burner"

class FukuokaYataiBurnerTest < Minitest::Test
  def test_the_unlisted_burner_is_model_not_found
    result = nil
    Multivitamin::Cassettes.play(__dir__, "yatai_burner") do
      result = FukuokaYataiBurner::YataiBurner.conduct
    end

    assert_equal "RubyLLM::ModelNotFoundError", result.error_class
    assert_equal "StandardError", result.superclass
    refute result.caught_as_provider_error
    assert_includes result.message, FukuokaYataiBurner::YataiBurner::DROPPED
    assert_includes result.message, "RubyLLM.models.refresh"
  end
end
