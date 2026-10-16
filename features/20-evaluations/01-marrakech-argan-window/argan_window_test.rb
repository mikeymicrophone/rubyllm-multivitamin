# frozen_string_literal: true

require "minitest/autorun"
require_relative "argan_window"

class MarrakechArganWindowTest < Minitest::Test
  def test_the_return_window_cases_pass
    report = nil
    Multivitamin::Cassettes.play(__dir__, "argan_window") do
      report = MarrakechArganWindow::ReturnWindow.conduct
    end

    assert_equal true, report.passed?
    assert_equal %w[unopened_tin market_day_tin], report.trials.map { |trial| trial.test_case.name }
    assert_match(/30/, report.trials.first.output.to_s)
    assert_match(/final/i, report.trials.last.output.to_s)
    assert_equal :passed, report.trials.first.evaluations.first.status
    assert_equal :correctness, report.trials.first.evaluations.first.name
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/argan_window.yml", __dir__))

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
