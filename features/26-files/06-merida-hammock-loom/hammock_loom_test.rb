# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "hammock_loom"

class MeridaHammockLoomNoUploadTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/hammock_loom.yml", __dir__)

  def test_the_flag_keeps_the_card_inline
    result = nil
    Multivitamin::Cassettes.play(__dir__, "hammock_loom") do
      result = MeridaHammockLoom::HammockLoom.conduct
    end

    refute result.auto_upload
    assert_includes result.brief, "Itzel"
    assert_includes result.brief, "MER-2026-1016-H7"
    assert_equal 1, interactions.length
    refute_includes interactions.fetch(0).dig("request", "uri"), "/files"
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
