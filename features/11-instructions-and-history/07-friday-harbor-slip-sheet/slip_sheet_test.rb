# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "slip_sheet"

class FridayHarborSlipSheetTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/slip_sheet.yml", __dir__)

  def test_short_orders_and_a_long_sheet
    result = nil
    Multivitamin::Cassettes.play(__dir__, "slip_sheet") do
      result = FridayHarborSlipSheet::SlipSheet.conduct
    end

    assert_operator result.system_length, :<, 200
    assert_operator result.user_length, :>, 400
    assert_includes result.assignment, "14"
    assert_includes result.assignment, "Cape Flattery"
    refute_includes result.assignment, "\n"
    assert_equal %i[system user assistant], result.roles
    assert_equal :stop, result.finish
  end

  def test_cassette_keeps_the_sheet_on_the_user_turn
    body = request_bodies.fetch(0)

    assert_includes body, "Answer in one sentence"
    assert_includes body, "Slip 14"
    assert_includes body, "Slip 27"
    assert_includes body, "Cape Flattery"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map { |hit|
      hit.dig("request", "body", "string")
    }
  end
end
