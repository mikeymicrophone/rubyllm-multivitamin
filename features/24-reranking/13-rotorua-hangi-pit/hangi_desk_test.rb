# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "hangi_desk"

class RotoruaHangiPitDeskTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/hangi_desk.yml", __dir__)

  def test_the_desk_briefs_pit_d
    result = nil
    Multivitamin::Cassettes.play(__dir__, "hangi_desk") do
      result = RotoruaHangiPit::HangiDesk.conduct
    end

    assert_equal 3, result.index
    assert_equal "D", result.pit
    assert_equal "school basket", result.kai
    assert_equal 3, result.count
    assert_includes result.brief, "D"
    assert_includes result.brief, "11:40"
    assert_equal %i[system user assistant], result.roles
    assert_equal 2, interactions.length
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end

  def interactions
    YAML.load_file(CASSETTE).fetch("http_interactions")
  end
end
