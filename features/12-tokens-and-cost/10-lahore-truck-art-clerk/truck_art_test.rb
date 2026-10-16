# frozen_string_literal: true

require "minitest/autorun"
require_relative "truck_art"

class LahoreTruckArtNilCostTest < Minitest::Test
  def test_an_unlisted_clerk_yields_nil_when_nobody_reported_a_price
    result = nil
    Multivitamin::Cassettes.play(__dir__, "truck_art") do
      result = LahoreTruckArtClerk::TruckArt.conduct
    end

    assert_includes result.brief, "Sohni Dharti"
    assert_includes result.brief, "06:40"
    assert_equal 0, result.live_cost
    assert_equal 0, result.live_reported
    assert_equal LahoreTruckArtClerk::TruckArt::UNLISTED, result.unlisted_id
    assert_match(/Assuming model exists/, result.unlisted_warning.to_s)
    assert_nil result.unlisted_input_price
    assert_equal 0, result.priced_with_reported
    assert_nil result.priced_bare
    assert_operator result.input_tokens, :>, 0
    assert_operator result.output_tokens, :>, 0
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/truck_art.yml", __dir__))

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
