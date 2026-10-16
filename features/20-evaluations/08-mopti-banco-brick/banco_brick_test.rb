# frozen_string_literal: true

require "json"
require "minitest/autorun"
require_relative "banco_brick"

class MoptiBancoBrickTest < Minitest::Test
  def test_the_eval_desk_writes_a_json_report
    result = nil
    Multivitamin::Cassettes.play(__dir__, "banco_brick") do
      result = MoptiBancoBrick::BrickDesk.conduct
    end

    assert_equal true, result.report.passed?
    assert_match(/64/, result.report.trials.first.output.to_s)
    assert_match(/Aissata/, result.report.trials.first.output.to_s)
    assert_path_exists result.path
    saved = JSON.parse(File.read(result.path))
    assert_equal "MoptiBrickEvaluation", saved.fetch("name")
    assert_equal 1, saved.dig("counts", "passed")
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/banco_brick.yml", __dir__))

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
