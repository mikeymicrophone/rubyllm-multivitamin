# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "buoy_check_in"

class BuoyCheckInTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/buoy_check_in.yml", __dir__)

  def test_the_follow_up_still_carries_the_recording
    result = nil
    Multivitamin::Cassettes.play(__dir__, "buoy_check_in") do
      result = EdizHookBuoyCheckIn::BuoyCheckIn.conduct
    end

    assert_includes result.check_in, "Alden"
    assert_match(/0?5:40/, result.check_in)
    assert_includes result.check_in, "12.6"
    assert_includes result.voltage, "12.6"
    assert_equal [1, 0], result.attachment_counts
    assert_equal %i[system user assistant user assistant], result.roles
    assert_equal :stop, result.finish
    assert_operator result.follow_up_input_tokens, :>=, result.input_tokens

    bodies = request_bodies
    assert_equal 2, bodies.length
    assert_equal 1, bodies.fetch(0).scan('"type":"input_audio"').length
    assert_equal 1, bodies.fetch(1).scan('"type":"input_audio"').length
    assert_operator bodies.fetch(1).bytesize, :>, bodies.fetch(0).bytesize
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map do |interaction|
      interaction.dig("request", "body", "string").to_s.dup.force_encoding(Encoding::UTF_8)
    end
  end
end
