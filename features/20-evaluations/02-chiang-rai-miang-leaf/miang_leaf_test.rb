# frozen_string_literal: true

require "minitest/autorun"
require_relative "miang_leaf"

class ChiangRaiMiangLeafTest < Minitest::Test
  def test_structured_inputs_reach_perform
    report = nil
    Multivitamin::Cassettes.play(__dir__, "miang_leaf") do
      report = ChiangRaiMiangLeaf::LeafGrade.conduct
    end

    assert_equal true, report.passed?
    trial = report.trials.first
    assert_equal "rack_count", trial.test_case.name
    assert_equal "CR-18", trial.test_case.inputs.fetch("lot")
    assert_match(/42/, trial.output.to_s)
    assert_match(/CR[-‑–]18/, trial.output.to_s)
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/miang_leaf.yml", __dir__))

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
