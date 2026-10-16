# frozen_string_literal: true

require "minitest/autorun"
require_relative "ginger_missing"

class NadiGingerShedMissingModelTest < Minitest::Test
  def test_omitting_model_stops_before_any_request
    result = nil
    Multivitamin::Cassettes.play(__dir__, "ginger_missing") do
      result = NadiGingerShed::GingerMissing.conduct
    end

    assert_instance_of ArgumentError, result.error
    assert_match(/model/, result.error.message)
    refute File.exist?(File.expand_path("cassettes/ginger_missing.yml", __dir__))
  end
end
