# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "retracted_sounding"

class EdizHookRetractedSoundingTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/retracted_sounding.yml", __dir__)

  def test_trimmed_transcript_drops_the_fouled_lead
    result = nil
    Multivitamin::Cassettes.play(__dir__, "retracted_sounding") do
      result = EdizHookRetractedSounding::RetractedSounding.conduct
    end

    assert_includes result.fouled, "14"
    assert_includes result.corrected, "22"
    assert_equal %i[system user assistant], result.roles_before_trim
    assert_equal %i[system], result.roles_after_trim
    assert_equal %i[system user assistant], result.roles
    refute result.trimmed_still_has_fouled
  end

  def test_second_request_does_not_resend_the_fouled_lead
    first, second = request_bodies

    assert_includes first, "Lead line under the buoy: 14 ft."
    refute_includes second, "Lead line under the buoy: 14 ft."
    assert_includes second, "22 ft"
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
