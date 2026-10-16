# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "shift_reset"

class MacauFuseResetTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/shift_reset.yml", __dir__)

  def test_reset_drops_the_overnight_board_before_mei_ling
    result = nil
    Multivitamin::Cassettes.play(__dir__, "shift_reset") do
      result = MacauFuseReset::ShiftReset.conduct
    end

    assert_match(/\A\s*Yes\b/i, result.night.to_s)
    assert_match(/fuse/i, result.night)
    assert_includes result.morning, "10:46"
    assert_includes result.morning, "Mei-Ling"
    assert_equal %i[system], result.roles_after_reset
    assert_equal %i[system user assistant], result.roles
    assert_equal :stop, result.night_finish
    assert_equal :stop, result.morning_finish
  end

  def test_second_request_is_a_fresh_morning_shift
    first, second = request_bodies

    assert_includes first, "overnight standing orders"
    assert_includes first, "07:05"
    assert_includes second, "morning standing orders"
    assert_includes second, "10:46"
    refute_includes second, "overnight standing orders"
    refute_includes second, "07:05"
    refute_includes second, "27 seconds"
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
