# frozen_string_literal: true

require "minitest/autorun"
require_relative "puppet_string"

class BrnoPuppetStringTest < Minitest::Test
  def test_custom_criterion_sits_beside_correctness
    report = nil
    Multivitamin::Cassettes.play(__dir__, "puppet_string") do
      report = BrnoPuppetString::StringCount.conduct
    end

    assert_equal true, report.passed?
    names = report.trials.first.evaluations.map(&:name)
    assert_equal %i[correctness names_the_bar], names
    assert_match(/Eliska/, report.trials.first.output.to_s)
    assert_includes report.trials.first.output.to_s, "9"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/puppet_string.yml", __dir__))

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
