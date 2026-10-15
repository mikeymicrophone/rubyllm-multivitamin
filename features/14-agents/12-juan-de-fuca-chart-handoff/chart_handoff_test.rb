# frozen_string_literal: true

require "minitest/autorun"
require_relative "chart_handoff"

class AgentJuanDeFucaChartHandoffTest < Minitest::Test
  def test_the_buoy_clerk_takes_the_chart_clerks_chat
    result = nil
    Multivitamin::Cassettes.play(__dir__, "chart_handoff") do
      result = JuanDeFucaChartHandoff::ChartNotice.conduct
    end

    assert result.same_object
    assert_includes result.correction, "2"
    assert_includes result.correction, "270"
    assert_includes result.ticket, "270"
    assert result.second_instructions.any? { |text| text.match?(/buoy clerk/i) }
    assert_operator result.roles.length, :>=, 5
    assert_includes result.roles, :system
    assert_equal :assistant, result.roles.last
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/chart_handoff.yml", __dir__))

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
