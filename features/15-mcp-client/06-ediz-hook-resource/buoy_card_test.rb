# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "buoy_card"

class EdizHookMcpResourceAttachTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/buoy_card.yml", __dir__)

  def test_the_battery_card_rides_as_an_attachment
    result = nil
    Multivitamin::Cassettes.play(__dir__, "buoy_card") do
      result = EdizHookMcpResource::BuoyCard.conduct
    end

    assert_equal "watch://ediz-hook/buoy-battery.md", result.uri
    assert_equal "text/markdown", result.mime_type
    assert_includes result.card_text, "14.8 V"
    assert_equal "buoy-battery.md", result.filename
    assert_equal :text, result.attachment_type
    assert_includes result.answer, "14.8"
    assert_includes result.answer, "EH-2"
    refute_includes result.roles, :tool
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
