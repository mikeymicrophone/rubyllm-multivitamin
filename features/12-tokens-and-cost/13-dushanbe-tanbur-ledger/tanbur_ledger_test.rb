# frozen_string_literal: true

require "minitest/autorun"
require_relative "tanbur_ledger"

class DushanbeTanburLedgerCapstoneTest < Minitest::Test
  def test_the_ledger_prints_each_turn_and_prices_the_work_on_two_models
    result = nil
    Multivitamin::Cassettes.play(__dir__, "tanbur_ledger") do
      result = DushanbeTanburLedger::TanburLedger.conduct
    end

    assert_equal 2, result.lines.size
    glue, player = result.lines
    assert_includes glue.content, "3.4"
    assert_includes glue.content, "04:25"
    assert_includes player.content, "Parvina"
    assert_includes player.content, "04:25"
    assert_equal %i[system user assistant user assistant], result.roles

    assert_equal result.lines.sum(&:input_tokens), result.chat_input
    assert_equal result.lines.sum(&:output_tokens), result.chat_output
    assert_equal 0, result.chat_cost
    result.lines.each { |line| assert_equal 0, line.cost_total }

    assert_equal 0.4, result.mini_input_price
    assert_equal 0.15, result.nano_input_price
    assert_operator result.mini_total, :>, result.nano_total
    assert_operator result.nano_total, :>, 0
    assert_equal "gpt-4o-mini", result.cheaper_id
    assert_equal true, result.under_budget
    assert_operator result.mini_total, :<, DushanbeTanburLedger::TanburLedger::WATCH_BUDGET
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/tanbur_ledger.yml", __dir__))

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
