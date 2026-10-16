# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "siapo_desk"

class ApiaSiapoPrintDeskTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/siapo_desk.yml", __dir__)

  def test_the_desk_holds_the_threat_and_briefs_sina
    result = nil
    Multivitamin::Cassettes.play(__dir__, "siapo_desk") do
      result = ApiaSiapoPrint::SiapoDesk.conduct
    end

    assert result.outer_flagged
    assert_equal [false, true, false], result.flags
    assert_includes result.brief, "Sina"
    assert_includes result.brief, "08:10"
    assert_equal %i[system user assistant], result.roles
    assert_equal 2, interactions.length
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
