# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "yaml"
require_relative "buoy_ticket"

class BuoyTicketTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/buoy_ticket.yml", __dir__)

  def test_optional_fields_drop_out_of_required_and_strict_mode
    result = nil
    Multivitamin::Cassettes.play(__dir__, "buoy_ticket") do
      result = EdizHookBuoyTicket::ServiceTicket.conduct
    end

    assert_equal "Ediz Hook bell", result.parsed["buoy"]
    assert_in_delta 12.4, result.parsed["volts"], 0.001
    assert_includes result.parsed["pencil_note"], "glass cloudy"
    refute result.parsed.key?("replaced_on")
    assert_equal %w[buoy volts pencil_note], result.parsed.keys
    assert_equal %i[system user assistant], result.roles
    assert_operator result.cost, :>, 0

    format = JSON.parse(request_bodies.fetch(0)).dig("text", "format")
    assert_equal "battery_ticket", format["name"]
    assert_equal false, format["strict"]
    assert_equal %w[buoy volts], format.dig("schema", "required")
    assert format.dig("schema", "properties").key?("replaced_on")
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map { |hit| hit.dig("request", "body", "string") }
  end
end
