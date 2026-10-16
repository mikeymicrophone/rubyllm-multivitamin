# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "funicular_card"

class ValparaisoFunicularFindDownloadTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/funicular_card.yml", __dir__)

  def test_find_and_download_round_trip_the_card
    result = nil
    Multivitamin::Cassettes.play(__dir__, "funicular_card") do
      result = ValparaisoFunicular::FunicularCard.conduct
    end

    assert result.same_id
    assert_includes result.found_filename, "funicular"
    assert_includes result.blob, "%PDF"
    assert_equal 3, interactions.length
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
