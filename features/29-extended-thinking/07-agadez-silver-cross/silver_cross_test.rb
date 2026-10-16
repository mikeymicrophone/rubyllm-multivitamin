# frozen_string_literal: true

require "minitest/autorun"
require_relative "silver_cross"

class AgadezSilverCrossNoOffControlTest < Minitest::Test
  def test_gpt_four_one_mini_has_no_off_control
    result = nil
    Multivitamin::Cassettes.play(__dir__, "silver_cross") do
      result = AgadezSilverCross::SilverCross.conduct
    end

    assert_instance_of ArgumentError, result.error
    assert_match(/no off control/i, result.message)
    assert_match(/gpt-4\.1-mini/, result.message)
    refute File.exist?(File.expand_path("cassettes/silver_cross.yml", __dir__))
  end
end
