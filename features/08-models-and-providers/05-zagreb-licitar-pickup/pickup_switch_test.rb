# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "pickup_switch"

class ZagrebLicitarSwitchTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/pickup_switch.yml", __dir__)

  def test_with_model_keeps_the_pickup_card_and_names_the_new_clerk
    result = nil
    Multivitamin::Cassettes.play(__dir__, "pickup_switch") do
      result = ZagrebLicitar::PickupSwitch.conduct
    end

    assert_includes result.opening_model, Multivitamin::Models::OPENAI_CHAT
    assert_match(/\A\s*Yes\b/i, result.opening.to_s)
    assert_includes result.opening, "Ivana"
    assert_includes result.opening, "10:15"

    assert_includes result.bus_model, Multivitamin::Models::OPENAI_CHAT_SWITCH
    assert_equal Multivitamin::Models::OPENAI_CHAT_SWITCH, result.chat_model_id
    refute_equal result.opening_model, result.bus_model
    assert_includes result.bus.to_s, "10:40"
    assert result.first_user_still_present
    assert_equal %i[system user assistant user assistant], result.roles
  end

  def test_cassette_shows_the_switched_model_id
    bodies = YAML.load_file(CASSETTE).fetch("http_interactions").map do |interaction|
      interaction.dig("request", "body", "string").to_s
    end

    assert_equal 2, bodies.size
    assert_includes bodies.fetch(0), Multivitamin::Models::OPENAI_CHAT
    refute_includes bodies.fetch(0), Multivitamin::Models::OPENAI_CHAT_SWITCH
    assert_includes bodies.fetch(1), Multivitamin::Models::OPENAI_CHAT_SWITCH
    assert_includes bodies.fetch(1), "Ivana"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
