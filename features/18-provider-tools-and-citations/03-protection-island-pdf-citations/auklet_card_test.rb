# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "auklet_card"

class ProviderToolsProtectionIslandPdfCitationsTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/auklet_card.yml", __dir__)

  def test_the_auklet_card_is_read_and_document_citations_stay_empty
    result = nil
    Multivitamin::Cassettes.play(__dir__, "auklet_card") do
      result = ProtectionIslandPdfCitations::AukletCard.conduct
    end

    assert_includes result.brief, "240"
    assert_includes result.brief, "10:46"
    assert_match(/Alden/i, result.brief)
    assert_equal [], result.citations
    assert_match(/does not support citations/i, result.warning)
    assert_match(/gpt-4\.1-mini/, result.warning)
    assert_equal :stop, result.finish
    assert_operator result.cost, :>, 0

    request = request_bodies.fetch(0)
    assert_includes request, '"type":"input_file"'
    assert_includes request, "data:application/pdf;base64,"
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
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
