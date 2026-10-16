# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "firing_plate"

class PersistedOaxacaAlebrijePlateTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/firing_plate.yml", __dir__)

  def test_the_persisted_log_sends_the_photograph
    result = nil
    Multivitamin::Cassettes.play(__dir__, "firing_plate") do
      result = OaxacaAlebrijePlate::FiringPlate.conduct
    end

    assert_includes result.brief, "08:20"
    assert_includes result.brief, "0.6"
    assert_includes result.brief, "11:05"
    assert_match(/Rufina/i, result.brief)
    assert_equal %i[system user assistant], result.roles
    assert_equal :stop, result.finish
    assert_operator result.input_tokens, :>, 0

    request = request_bodies.fetch(0)
    assert_includes request, "data:image/png;base64,"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-(?:or-v1-)?[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map do |interaction|
      interaction.dig("request", "body", "string").to_s.dup.force_encoding(Encoding::UTF_8)
    end
  end
end
