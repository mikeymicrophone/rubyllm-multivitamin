# frozen_string_literal: true

require "minitest/autorun"
require_relative "log_boom"

class LogBoomTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/log_boom.yml", __dir__)

  def test_the_boom_count_reports_each_stick_pocket
    result = nil
    Multivitamin::Cassettes.play(__dir__, "log_boom") do
      result = DewattoProgressReports::BoomClerk.conduct
    end

    assert_equal DewattoProgressReports::LogBoomCount::CARD, result.callback_result
    assert_equal DewattoProgressReports::LogBoomCount::CARD, result.tool_content
    assert_kind_of Hash, result.tool_arguments
    assert_equal 4, result.progress_notes.size
    assert_includes result.progress_notes.first, "12-A"
    assert_includes result.progress_notes.last, "12-D"
    assert_equal [1, 2, 3, 4], result.values
    assert_equal [4, 4, 4, 4], result.totals
    assert_equal [0.25, 0.5, 0.75, 1.0], result.fractions
    assert_includes result.answer, "186"
    assert_includes result.answer, "12-D"
    assert_equal %i[system user assistant tool assistant], result.roles
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
