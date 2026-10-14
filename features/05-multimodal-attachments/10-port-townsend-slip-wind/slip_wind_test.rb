# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "slip_wind"

class WindBookTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/slip_wind.yml", __dir__)

  def test_the_workbook_becomes_text_and_the_original_stays
    result = nil
    Multivitamin::Cassettes.play(__dir__, "slip_wind") do
      result = PortTownsendWindBook::SlipWind.conduct
    end

    assert_includes result.replacement, "North float"
    assert_includes result.replacement, "28"
    assert_includes result.replacement, "242"
    assert_includes result.replacement, "06:10"
    assert_includes result.reading, "28"
    assert_includes result.reading, "242"
    assert_includes result.reading, "06:10"
    assert_match(/north float/i, result.reading)
    assert_equal "slip-wind.xlsx", result.kept_name
    assert_equal :document, result.kept_type
    assert_equal :stop, result.finish
    assert_operator result.cost, :>, 0

    request = request_bodies.fetch(0)
    assert_includes request, "<file name='slip-wind.txt' mime_type='text/plain'>"
    assert_includes request, "North float, gust 28 knots"
    refute_includes request, "spreadsheetml"
    refute_includes request, "PK\u0003\u0004"
  end

  def test_the_sheet_reader_without_a_model
    text = PortTownsendWindBook::WindBook.plain_text(
      RubyLLM::Attachment.new(PortTownsendWindBook::SlipWind::BOOK)
    )

    assert_includes text, "Port Townsend ferry slip wind book."
    assert_includes text, "North float, gust 28 knots, direction 242 degrees, clock 06:10."
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
