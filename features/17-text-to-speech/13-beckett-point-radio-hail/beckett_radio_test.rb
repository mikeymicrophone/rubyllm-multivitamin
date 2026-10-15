# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "beckett_radio"

class BeckettPointRadioHailCapstoneTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/beckett_radio.yml", __dir__)

  def test_the_radio_card_is_asked_spoken_and_saved
    result = nil
    Multivitamin::Cassettes.play(__dir__, "beckett_radio") do
      result = BeckettPointRadioHail::BeckettRadio.conduct
    end

    assert_includes result.answer, "Beckett Point"
    assert_includes result.answer, "Alden"
    assert_equal "tts-1", result.speech_model
    assert_equal %i[system user assistant], result.roles
    assert_equal result.file_bytes, File.binread(result.saved_path)
    assert_equal 0xFF, result.file_bytes.getbyte(0)
    assert_match(/radio_card\.mp3\z/, result.saved_path)

    bodies = request_bodies
    assert_equal 2, bodies.length
    assert_includes bodies.fetch(0), '"model":"gpt-4.1-mini"'
    assert_includes bodies.fetch(0), "Beckett Point"
    assert_includes bodies.fetch(1), '"model":"tts-1"'
    assert_includes bodies.fetch(1), result.answer
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
