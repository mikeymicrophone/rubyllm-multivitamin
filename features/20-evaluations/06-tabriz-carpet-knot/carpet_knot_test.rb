# frozen_string_literal: true

require "minitest/autorun"
require_relative "carpet_knot"

class TabrizCarpetKnotTest < Minitest::Test
  def test_the_judge_probability_passes_the_minimum
    report = nil
    Multivitamin::Cassettes.play(__dir__, "carpet_knot") do
      report = TabrizCarpetKnot::KnotCount.conduct
    end

    assert_equal true, report.passed?
    item = report.trials.first.evaluations.first
    assert_equal :agrees, item.name
    assert_equal :passed, item.status
    assert_match(/86/, report.trials.first.output.to_s)
    assert_match(/Farhad/, report.trials.first.output.to_s)
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/carpet_knot.yml", __dir__))

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
