# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "retablo_lot"

class AyacuchoRetabloLotReuseTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/retablo_lot.yml", __dir__)

  def test_one_upload_serves_two_asks
    result = nil
    Multivitamin::Cassettes.play(__dir__, "retablo_lot") do
      result = AyacuchoRetabloLot::RetabloLot.conduct
    end

    assert_match(/\Afile-/, result.file_id)
    assert_includes result.boxes, "12"
    assert_includes result.clock, "10:05"
    assert_equal 3, interactions.length
    assert_includes interactions.fetch(0).dig("request", "uri"), "/files"
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
