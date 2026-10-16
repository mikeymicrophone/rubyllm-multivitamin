# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "copra_sheet"

class LaeCopraSheetInlineTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/copra_sheet.yml", __dir__)

  def test_the_small_sheet_stays_inline
    result = nil
    Multivitamin::Cassettes.play(__dir__, "copra_sheet") do
      result = LaeCopraSheet::CopraSheet.conduct
    end

    assert result.auto_upload
    assert_operator result.byte_size, :<, 50 * 1024 * 1024
    assert_includes result.brief, "Naomi"
    assert_includes result.brief, "LAE-2026-1016-C4"
    assert_equal 1, interactions.length
    refute_includes interactions.fetch(0).dig("request", "uri"), "/files"
    assert_includes request_body, "file_data"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def interactions
    YAML.load_file(CASSETTE).fetch("http_interactions")
  end

  def request_body
    interactions.fetch(0).dig("request", "body", "string").to_s
  end
end
