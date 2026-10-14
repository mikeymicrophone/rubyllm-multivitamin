# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "drawer_label"

class DrawerLabelTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/drawer_label.yml", __dir__)

  def test_high_detail_keeps_the_focal_length
    result = nil
    Multivitamin::Cassettes.play(__dir__, "drawer_label") do
      result = NewDungenessDrawerLabel::DrawerLabel.conduct
    end

    assert_equal :high, result.resolution
    assert_includes result.reading, "4"
    assert_includes result.reading, "375"
    assert_match(/drawer/i, result.reading)
    assert_equal :stop, result.finish
    assert_operator result.input_tokens, :>, 0
    assert_operator result.cost, :>, 0

    request = request_bodies.fetch(0)
    assert_includes request, '"type":"input_image"'
    assert_includes request, '"detail":"high"'
    assert_includes request, "data:image/png;base64,"
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
