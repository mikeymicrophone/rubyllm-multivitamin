# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "yaml"
require_relative "buoy_battery"

class BuoyBatteryTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/buoy_battery.yml", __dir__)

  def test_a_miss_comes_back_as_json_and_the_tender_tries_again
    skip "cassette pending live recording" unless File.exist?(CASSETTE) || Multivitamin::Cassettes.live?

    result = nil
    Multivitamin::Cassettes.play(__dir__, "buoy_battery") do
      result = EdizHookBuoyBattery::BatteryRound.conduct
    end

    assert_equal 2, result.tool_contents.size
    miss = JSON.parse(result.tool_contents.fetch(0))
    assert_includes miss.fetch("error"), "LL-17"
    assert_includes miss.fetch("error"), "LL-4"
    assert_equal EdizHookBuoyBattery::BuoyBattery::CARDS.fetch("LL-4"), result.tool_contents.fetch(1)
    assert_includes result.answer, "12.6"
    assert_equal %i[system user assistant tool assistant tool assistant], result.roles

    bodies = YAML.load_file(CASSETTE).fetch("http_interactions").map { |interaction| interaction.dig("request", "body", "string") }
    assert_includes bodies.fetch(0), '"tool_choice":"required"'
    refute_includes bodies.fetch(0), "12.6"
    refute_includes bodies.fetch(1), '"tool_choice"'
    assert_includes bodies.fetch(1), "LL-17"
    refute_includes bodies.fetch(1), "12.6"
    assert_includes bodies.fetch(2), "12.6"
  end

  def test_a_missing_buoy_returns_an_error_hash_and_a_known_buoy_returns_a_string
    tool = EdizHookBuoyBattery::BuoyBattery.new
    miss = tool.execute(buoy: "LL-17")

    assert_kind_of Hash, miss
    assert_includes miss.fetch(:error), "LL-4"
    assert_kind_of String, tool.execute(buoy: "ll-4")
    assert_includes tool.class.split_result(miss).first, '"error"'
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette pending live recording" unless File.exist?(CASSETTE)

    cassette = File.read(CASSETTE)

    refute_match(/sk-or-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
