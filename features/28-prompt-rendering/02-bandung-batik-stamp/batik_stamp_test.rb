# frozen_string_literal: true

require "minitest/autorun"
require_relative "batik_stamp"

class BandungBatikStampMissingTest < Minitest::Test
  def test_a_missing_canting_prompt_raises_before_http
    result = nil
    Multivitamin::Cassettes.play(__dir__, "batik_stamp") do
      result = BandungBatikStamp::BatikStamp.conduct
    end

    assert_instance_of RubyLLM::PromptNotFoundError, result.error
    assert_equal "StandardError", result.superclass
    refute result.caught_as_provider
    assert_match(/Prompt file not found/, result.message)
    refute File.exist?(File.expand_path("cassettes/batik_stamp.yml", __dir__))
  end
end
