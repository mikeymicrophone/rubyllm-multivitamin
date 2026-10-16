# frozen_string_literal: true

require "minitest/autorun"
require_relative "cable_car_batch"

class WellingtonCableCarBatchTest < Minitest::Test
  def test_cable_car_batch_restores_each_context
    result = Multivitamin::Cassettes.play(__dir__, "cable_car_batch") { WellingtonCableCarBatch.conduct }

    assert_equal 2, result.fetch(:jobs)
    assert_equal 2, result.fetch(:assistant_count)
    assert_equal "openrouter", result.fetch(:provider)
    assert_includes result.fetch(:briefs).first, "Kelburn"
    assert_includes result.fetch(:briefs).last, "09:05"
  end

  def test_cassette_has_no_live_key
    cassette = File.binread(File.join(__dir__, "cassettes/cable_car_batch.yml"))
    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
