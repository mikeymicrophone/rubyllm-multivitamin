# frozen_string_literal: true

require "minitest/autorun"
require_relative "slip_find"

class AgentPortTownsendSlipFindTest < Minitest::Test
  def test_find_reuses_the_slip_and_the_gust
    result = nil
    Multivitamin::Cassettes.play(__dir__, "slip_find") do
      result = PortTownsendSlipFind::WindBoard.conduct
    end

    assert result.same_id
    assert_equal "PortTownsendSlipFind::SlipChat", result.found_class
    assert_includes result.opening, "28"
    assert_match(/Kalakala/i, result.opening)
    assert_includes result.follow_up, "28"
    assert_match(/Kalakala/i, result.follow_up)
    assert_equal 1, result.system_count
    assert_equal %i[system user assistant user assistant], result.roles
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/slip_find.yml", __dir__))

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
