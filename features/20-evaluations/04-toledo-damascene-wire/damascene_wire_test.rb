# frozen_string_literal: true

require "minitest/autorun"
require_relative "damascene_wire"

class ToledoDamasceneWireTest < Minitest::Test
  def test_the_tool_round_is_on_the_trial
    report = nil
    Multivitamin::Cassettes.play(__dir__, "damascene_wire") do
      report = ToledoDamasceneWire::WireCount.conduct
    end

    assert_equal true, report.passed?
    trial = report.trials.first
    assert_includes trial.output.to_s, "14"
    assert_match(/Inés|Ines/, trial.output.to_s)
    roles = trial.result.respond_to?(:messages) ? trial.result.messages.map(&:role) : []
    if roles.empty? && trial.result.respond_to?(:role)
      assert_equal :assistant, trial.result.role
    else
      assert_includes roles, :tool
    end
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/damascene_wire.yml", __dir__))

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
