# frozen_string_literal: true

require "minitest/autorun"
require_relative "river_gauge"

class RiverGaugeTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/river_gauge.yml", __dir__)

  def test_the_loop_stops_on_the_staff_without_a_speech
    result = nil
    Multivitamin::Cassettes.play(__dir__, "river_gauge") do
      result = DosewallipsGenerateRunTools::ParkGauge.conduct
    end

    refute result.read_after_generate
    assert result.read_after_tools
    refute result.settled
    assert_equal DosewallipsGenerateRunTools::RiverStaff::CARD, result.chit
    assert_includes result.chit, "4.6"
    assert_equal :tool, result.roles.last
    assert_equal :assistant, result.roles[-2]
    assert_equal %i[system user assistant tool], result.roles
  end

  def test_halt_is_not_a_tool_method
    refute DosewallipsGenerateRunTools::RiverStaff.method_defined?(:halt)
    refute DosewallipsGenerateRunTools::RiverStaff.private_method_defined?(:halt)
    refute defined?(RubyLLM::Tool::Halt)
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
