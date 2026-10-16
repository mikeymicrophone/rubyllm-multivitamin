# frozen_string_literal: true

require "minitest/autorun"
require_relative "tsampa_mill"

class LhasaTsampaMillTest < Minitest::Test
  def test_the_grader_sees_both_mill_turns
    report = nil
    Multivitamin::Cassettes.play(__dir__, "tsampa_mill") do
      report = LhasaTsampaMill::MillTurns.conduct
    end

    assert_equal true, report.passed?
    trial = report.trials.first
    assert_instance_of RubyLLM::Chat, trial.result
    assert_equal %i[system user assistant user assistant], trial.result.messages.map(&:role)
    spoken = trial.result.messages.select { |message| message.role == :assistant }.map(&:content).join(" ")
    assert_match(/1,?080/, spoken)
    assert_match(/09:15|9:15/, spoken)
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/tsampa_mill.yml", __dir__))

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
