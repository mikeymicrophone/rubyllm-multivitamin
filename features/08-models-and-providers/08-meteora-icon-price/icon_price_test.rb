# frozen_string_literal: true

require "minitest/autorun"
require_relative "icon_price"

class MeteoraIconPriceTest < Minitest::Test
  def test_image_model_prices_are_nil_or_numeric_and_unknown_kinds_raise
    result = nil
    Multivitamin::Cassettes.play(__dir__, "icon_price") do
      result = MeteoraIcon::IconPrice.conduct
    end

    assert_operator result.image_count, :>, 10
    assert_equal result.image_count, result.input_kinds.size
    result.input_kinds.each do |price|
      assert price.nil? || price.is_a?(Numeric), "expected nil or Numeric, got #{price.inspect}"
    end
    assert result.input_kinds.any?(&:nil?)
    assert result.input_kinds.any? { |price| price.is_a?(Numeric) }

    assert_equal "gemini-2.5-flash-image", result.flash_id
    assert_equal "gemini", result.flash_provider
    assert_equal "gemini-flash", result.flash_family
    assert_equal :image, result.flash_type
    assert_equal 0.3, result.flash_input
    assert_equal 30, result.flash_output

    assert_equal "ArgumentError", result.unknown_kind_error
    assert_includes result.unknown_kind_message, "Unknown price kind"
    assert_includes result.unknown_kind_message, "input"
    assert_includes result.unknown_kind_message, "output"
  end
end
