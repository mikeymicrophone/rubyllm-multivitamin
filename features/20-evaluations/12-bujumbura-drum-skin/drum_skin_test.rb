# frozen_string_literal: true

require "minitest/autorun"
require_relative "drum_skin"

class BujumburaDrumSkinTest < Minitest::Test
  def test_the_wrong_skin_count_fails_correctness
    report = nil
    Multivitamin::Cassettes.play(__dir__, "drum_skin") do
      report = BujumburaDrumSkin::SkinCount.conduct
    end

    refute report.passed?
    trial = report.trials.first
    assert_equal :failed, trial.status
    item = trial.evaluations.first
    assert_equal :correctness, item.name
    assert_equal :failed, item.status
    assert_match(/18/, trial.output.to_s)
    assert_match(/Immaculee/, trial.output.to_s)
    refute_match(/\b14\b/, trial.output.to_s)
    assert item.reason || report.to_s.match?(/correctness/)
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/drum_skin.yml", __dir__))

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
