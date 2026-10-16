# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "salsa_plaza"

class CaliSalsaPlazaTopNTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/salsa_plaza.yml", __dir__)

  def test_top_n_returns_five_of_eight
    result = nil
    Multivitamin::Cassettes.play(__dir__, "salsa_plaza") do
      result = CaliSalsaPlaza::SalsaPlaza.conduct
    end

    assert_equal 5, result.count
    assert result.documents.any? { |card| card.include?("Calle Quinta") }
    assert_includes request_body, '"top_n":5'
    assert_includes request_body, "Vallenato"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end

  def request_body
    YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0).dig("request", "body", "string").to_s
  end
end
