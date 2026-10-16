# frozen_string_literal: true

require "minitest/autorun"
require_relative "alabaster_vase"

class LuxorAlabasterVaseTest < Minitest::Test
  def test_cost_is_nil_until_the_batch_completes
    result = nil
    Multivitamin::Cassettes.play(__dir__, "alabaster_vase") do
      result = LuxorAlabasterVase::VaseBatch.conduct
    end

    if result.complete
      assert_includes %i[succeeded failed cancelled], result.status
    else
      assert_nil result.cost_total
      assert_equal :pending, result.status
    end
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/alabaster_vase.yml", __dir__))

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
