# frozen_string_literal: true

require "minitest/autorun"
require_relative "paper_vat"

class SamarkandPaperVatTest < Minitest::Test
  def test_the_vat_desk_passes_both_cases_and_saves_tokens
    result = nil
    Multivitamin::Cassettes.play(__dir__, "paper_vat") do
      result = SamarkandPaperVat::VatDesk.conduct
    end

    assert_equal true, result.report.passed?
    assert_equal %w[vat_count sizing_window], result.progress
    names = result.report.trials.first.evaluations.map(&:name)
    assert_equal %i[correctness names_the_vat], names
    assert_operator result.report.tokens.input, :>, 0
    assert_equal result.report.tokens.input, result.saved.dig("tokens", "input")
    assert_match(/27/, result.report.trials.first.output.to_s)
    assert_match(/Dilshod/, result.report.trials.first.output.to_s)
    assert_match(/14:40/, result.report.trials.last.output.to_s)
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/paper_vat.yml", __dir__))

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
