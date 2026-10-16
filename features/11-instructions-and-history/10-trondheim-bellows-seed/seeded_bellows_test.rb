# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "seeded_bellows"

class TrondheimBellowsSeedTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/seeded_bellows.yml", __dir__)

  def test_seeded_card_is_corrected_on_the_next_turn
    result = nil
    Multivitamin::Cassettes.play(__dir__, "seeded_bellows") do
      result = TrondheimBellowsSeed::SeededBellows.conduct
    end

    assert_equal %i[system user assistant], result.roles_before_ask
    assert_equal %i[system user assistant user assistant], result.roles
    assert_equal TrondheimBellowsSeed::SeededBellows::SEEDED_ASSISTANT, result.seeded_assistant
    assert_includes result.correction, "9"
    assert_includes result.correction, "2.2"
    refute_includes result.correction, "8 folds"
  end

  def test_cassette_has_one_round_trip_that_carries_the_seed
    bodies = request_bodies

    assert_equal 1, bodies.length
    assert_includes bodies.first, "8 folds"
    assert_includes bodies.first, "2.0 kPa"
    assert_includes bodies.first, "9 folds"
    assert_includes bodies.first, "2.2 kPa"
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
