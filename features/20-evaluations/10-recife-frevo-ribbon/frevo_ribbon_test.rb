# frozen_string_literal: true

require "minitest/autorun"
require_relative "frevo_ribbon"

class RecifeFrevoRibbonTest < Minitest::Test
  def test_assertions_compare_output_to_the_expected_card
    report = nil
    Multivitamin::Cassettes.play(__dir__, "frevo_ribbon") do
      report = RecifeFrevoRibbon::RibbonCount.conduct
    end

    assert_equal true, report.passed?
    trial = report.trials.first
    assert_equal "ribbon_count", trial.test_case.name
    assert_operator trial.assertion_count, :>=, 3
    assert_nil trial.assertion_failure
    assert_empty trial.evaluations
    assert_match(/Moacir/, trial.output.to_s)
    assert_match(/Moacir/, trial.test_case.expected_output.to_s)
    refute_equal trial.test_case.expected_output.to_s, trial.output.to_s
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/frevo_ribbon.yml", __dir__))

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
