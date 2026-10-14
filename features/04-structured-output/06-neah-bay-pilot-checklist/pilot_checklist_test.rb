# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "yaml"
require_relative "pilot_checklist"

class PilotChecklistTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/pilot_checklist.yml", __dir__)

  def test_the_checklist_uses_the_name_set_on_the_hash
    result = nil
    Multivitamin::Cassettes.play(__dir__, "pilot_checklist") do
      result = NeahBayPilotChecklist::BoardingChecklist.conduct
    end

    assert_includes result.parsed["ship"], "Nordic Tidemoor"
    assert_equal "Neah Bay", result.parsed["boarding_station"]
    assert_equal true, result.parsed["ladder_ready"]
    assert_equal "port", result.parsed["lee_side"]
    assert_equal ["manropes rove", "deck lights on"], result.parsed["steps"].map { |step| step["item"] }
    assert result.parsed["steps"].all? { |step| step["ready"] == true }
    assert_equal %i[system user assistant], result.roles
    assert_operator result.cost, :>, 0

    format = JSON.parse(request_bodies.fetch(0)).dig("text", "format")
    assert_equal "PilotBoardingChecklist", format["name"]
    refute_equal "response", format["name"]
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
