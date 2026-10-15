# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "afternoon_relief"

class BremertonAfternoonReliefTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/afternoon_relief.yml", __dir__)

  def test_replacement_system_message_lands_after_the_morning_turns
    result = nil
    Multivitamin::Cassettes.play(__dir__, "afternoon_relief") do
      result = BremertonAfternoonRelief::AfternoonRelief.conduct
    end

    assert_match(/\A\s*Yes\b/i, result.morning.to_s)
    assert_includes result.morning, "18.4"
    assert_match(/\A\s*Afternoon\b/, result.afternoon.to_s)
    assert_includes result.afternoon, "18.4"
    assert_equal %i[user assistant system], result.roles_after_replace
    assert_equal 1, result.system_after_replace.length
    assert_includes result.system_after_replace.first, "afternoon standing orders"
    refute_includes result.system_after_replace.first, "morning standing orders"
    assert_equal %i[user assistant system user assistant], result.roles
  end

  def test_second_request_sends_afternoon_orders
    first, second = request_bodies

    assert_includes first, "morning standing orders"
    refute_includes first, "afternoon standing orders"
    assert_includes second, "afternoon standing orders"
    refute_includes second, "morning standing orders"
    assert_includes second, "18.4"
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
