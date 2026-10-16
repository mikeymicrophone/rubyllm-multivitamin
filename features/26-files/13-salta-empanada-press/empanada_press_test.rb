# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "empanada_press"

class SaltaEmpanadaPressCapstoneTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/empanada_press.yml", __dir__)

  def test_the_desk_uploads_finds_asks_and_refuses_the_download
    result = nil
    Multivitamin::Cassettes.play(__dir__, "empanada_press") do
      result = SaltaEmpanadaPress::EmpanadaPress.conduct
    end

    assert_equal result.file_id, result.found_id
    assert_includes result.brief, "Ines"
    assert_includes result.brief, "SLA-2026-1016-E2"
    assert_instance_of RubyLLM::BadRequestError, result.download_error
    assert_match(/user_data/, result.download_error.message)
    assert_equal 4, interactions.length
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def interactions
    YAML.load_file(CASSETTE).fetch("http_interactions")
  end
end
