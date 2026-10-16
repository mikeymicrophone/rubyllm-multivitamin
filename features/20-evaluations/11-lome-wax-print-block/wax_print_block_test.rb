# frozen_string_literal: true

require "minitest/autorun"
require_relative "wax_print_block"

class LomeWaxPrintBlockTest < Minitest::Test
  def test_the_progress_block_sees_each_case_in_order
    result = nil
    Multivitamin::Cassettes.play(__dir__, "wax_print_block") do
      result = LomeWaxPrintBlock::BlockCount.conduct
    end

    assert_equal true, result.report.passed?
    assert_equal %w[block_count stamp_clerk], result.progress
    assert_equal result.progress, result.report.trials.map { |trial| trial.test_case.name }
    assert_match(/11/, result.report.trials.first.output.to_s)
    assert_match(/Afi/, result.report.trials.last.output.to_s)
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/wax_print_block.yml", __dir__))

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
