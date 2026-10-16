# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../support/research_assertions"
require_relative "moai_budget"

class RapaNuiMoaiBudgetTest < Minitest::Test
  include Multivitamin::ResearchAssertions

  CASSETTE = File.expand_path("cassettes/moai_budget.yml", __dir__)

  def test_moai_budget_research_flow
    receipt = Multivitamin::Cassettes.play(__dir__, "moai_budget") { RapaNuiMoaiBudget.conduct }
    refute receipt.fetch(:complete)
    assert_equal :max_tokens, receipt.fetch(:finish_reason)
    assert_includes receipt.fetch(:brief), "Rapa Nui"
    assert_includes receipt.fetch(:brief), "unresolved"
    refute_nil receipt.fetch(:follow_up)
  end

  def test_cassette_does_not_carry_a_live_key
    assert_research_credentials_filtered
  end
end
