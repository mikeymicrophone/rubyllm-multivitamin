# frozen_string_literal: true

require "minitest/autorun"
require_relative "sunflower_press"

class ChisinauSunflowerPressTest < Minitest::Test
  def test_two_models_raise_before_upload
    result = ChisinauSunflowerPress::PressModels.conduct

    assert_equal "RubyLLM::Error", result.error_class
    assert_match(/one model/i, result.message)
  end
end
