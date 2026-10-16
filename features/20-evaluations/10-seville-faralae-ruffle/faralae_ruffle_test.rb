# frozen_string_literal: true

require "minitest/autorun"
require_relative "faralae_ruffle"

class SevilleFaralaeRuffleTest < Minitest::Test
  def test_assertions_compare_output_to_the_expected_card
    report = nil
    Multivitamin::Cassettes.play(__dir__, "faralae_ruffle") do
      report = SevilleFaralaeRuffle::RuffleCount.conduct
    end

    assert_equal true, report.passed?
    trial = report.trials.first
    assert_equal "ruffle_count", trial.test_case.name
    assert_operator trial.assertion_count, :>=, 3
    assert_nil trial.assertion_failure
    assert_empty trial.evaluations
    assert_match(/Rafaela/, trial.output.to_s)
    assert_match(/Rafaela/, trial.test_case.expected_output.to_s)
    refute_equal trial.test_case.expected_output.to_s, trial.output.to_s
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/faralae_ruffle.yml", __dir__))

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
