# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "berth_sheet"

class BerthSheetTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/berth_sheet.yml", __dir__)
  SHEET = FridayHarborBerthSheet::BerthSheet::SHEET

  def test_the_trusted_url_is_forwarded
    result = nil
    Multivitamin::Cassettes.play(__dir__, "berth_sheet") do
      result = FridayHarborBerthSheet::BerthSheet.conduct
    end

    assert_match(/Friday Harbor/i, result.reading)
    assert_match(/San Juan/i, result.reading)
    assert_equal :stop, result.finish
    assert_operator result.input_tokens, :>, 0
    assert_operator result.cost, :>, 0

    request = request_bodies.fetch(0)
    assert_includes request, SHEET
    assert_includes request, '"type":"input_image"'
    refute_includes request, "data:image"
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
