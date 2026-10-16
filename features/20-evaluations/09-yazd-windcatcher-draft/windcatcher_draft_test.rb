# frozen_string_literal: true

require "minitest/autorun"
require_relative "windcatcher_draft"

class YazdWindcatcherDraftTest < Minitest::Test
  def test_the_json_report_carries_tokens
    result = nil
    Multivitamin::Cassettes.play(__dir__, "windcatcher_draft") do
      result = YazdWindcatcherDraft::DraftWindow.conduct
    end

    assert_equal true, result.report.passed?
    assert_operator result.report.tokens.input, :>, 0
    assert_equal result.report.tokens.input, result.saved.dig("tokens", "input_tokens")
    assert_equal result.report.id, result.saved.fetch("id")
    assert_match(/10:20/, result.report.trials.first.output.to_s)
    assert_match(/Shirin/, result.report.trials.first.output.to_s)
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/windcatcher_draft.yml", __dir__))

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
