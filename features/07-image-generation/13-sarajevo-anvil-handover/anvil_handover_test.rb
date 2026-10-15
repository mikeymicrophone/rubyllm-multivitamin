# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "anvil_handover"

class SarajevoPaintedAnvilTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/anvil_handover.yml", __dir__)

  def test_the_relief_is_asked_about_the_saved_plate
    result = nil
    Multivitamin::Cassettes.play(__dir__, "anvil_handover") do
      result = SarajevoAnvilHandover::AnvilHandover.conduct
    end

    assert_equal "gpt-image-1-mini", result.paint_model
    assert_includes result.answer, "Kazandziluk"
    assert_match(/plate/i, result.answer)
    assert_equal %i[system user assistant], result.roles

    bodies = request_bodies
    assert_equal 2, bodies.length
    assert_includes bodies.fetch(0), '"model":"gpt-image-1-mini"'
    assert_includes bodies.fetch(0), "DZ-41"
    assert_includes bodies.fetch(1), '"model":"gpt-4.1-mini"'
    assert_includes bodies.fetch(1), "input_image"
    assert_includes bodies.fetch(1), "painted anvil-table plate"
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map do |interaction|
      interaction.dig("request", "body", "string")
    end
  end
end
