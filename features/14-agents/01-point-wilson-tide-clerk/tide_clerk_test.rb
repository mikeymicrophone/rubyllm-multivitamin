# frozen_string_literal: true

require "minitest/autorun"
require_relative "tide_clerk"

class AgentPointWilsonTideClerkTest < Minitest::Test
  def test_the_agent_briefs_the_board_and_keeps_the_macros
    result = nil
    Multivitamin::Cassettes.play(__dir__, "tide_clerk") do
      result = PointWilsonTideClerk::WatchBrief.conduct
    end

    assert_equal "PointWilsonTideClerk::TideClerk", result.agent_class
    assert_includes PointWilsonTideClerk::TideClerk.ancestors, RubyLLM::Agent
    assert_equal "RubyLLM::Chat", PointWilsonTideClerk::TideClerk.chat(**Multivitamin::Models.chat(provider: :openai)).class.name
    assert_equal Multivitamin::Models::OPENAI_CHAT, result.declared_model

    assert_includes result.opening, "Alden"
    assert_includes result.opening, "Retort"
    assert_includes result.opening, "10:46"
    assert_includes result.opening, "08:57"

    assert_includes result.follow_up, "Alden"
    assert_match(/09:30|9:30/, result.follow_up)
    assert_match(/lens/i, result.follow_up)

    assert_equal %i[system user assistant user assistant], result.roles
    assert_equal :stop, result.opening_finish
    assert_operator result.opening_input_tokens, :>, 0
    assert_operator result.opening_cost, :>=, 0
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/tide_clerk.yml", __dir__))

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
