# frozen_string_literal: true

require "minitest/autorun"
require_relative "retort_inputs"

class AgentAnacortesRetortInputsTest < Minitest::Test
  def test_lazy_instructions_name_the_retort_from_inputs
    result = nil
    Multivitamin::Cassettes.play(__dir__, "retort_inputs") do
      result = AnacortesRetortInputs::MorningCook.conduct
    end

    assert_equal [:retort], result.declared_inputs
    assert_includes result.instructions, "Retort No. 2"
    assert_includes result.instructions, "Basket 3"
    assert_includes result.instructions, "242"
    assert_includes result.log_line, "Retort No. 2"
    assert_includes result.log_line, "Basket 3"
    assert_includes result.log_line, "242"
    assert_equal %i[system user assistant], result.roles
    assert_equal "Retort No. 2", result.retort_name
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/retort_inputs.yml", __dir__))

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
