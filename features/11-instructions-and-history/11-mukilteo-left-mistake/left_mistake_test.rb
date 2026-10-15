# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "left_mistake"

class MukilteoLeftMistakeTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/left_mistake.yml", __dir__)

  def test_wrong_rear_flash_stays_while_the_front_is_read
    result = nil
    Multivitamin::Cassettes.play(__dir__, "left_mistake") do
      result = MukilteoLeftMistake::LeftMistake.conduct
    end

    assert result.mistake_still_present
    assert_equal %i[system user assistant user assistant], result.roles
    assert_match(/4/, result.front)
    assert_match(/front/i, result.front)
  end

  def test_next_request_still_carries_six_seconds
    body = request_bodies.fetch(0)

    assert_includes body, "6 seconds"
    assert_includes body, "2.5 seconds"
    assert_includes body, "front range interval"
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
