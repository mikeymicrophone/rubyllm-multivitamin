# frozen_string_literal: true

require "minitest/autorun"
require_relative "bridge_opening"

class BridgeOpeningTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/bridge_opening.yml", __dir__)

  def test_the_ledger_resolver_grants_the_lift
    result = nil
    Multivitamin::Cassettes.play(__dir__, "bridge_opening") do
      result = UnionResolverBlock::BridgeTender.conduct
    end

    assert result.awaiting
    assert_operator result.consults_before_grant, :>=, 1
    refute result.opened_before_grant
    assert result.opened_after
    assert_includes result.tool_content, "Salish Star"
    assert_includes result.tool_content, "14 minutes"
    assert_includes result.answer, "Salish Star"
    assert_includes result.answer, "14"
    assert_equal %i[system user assistant tool assistant], result.roles
  end

  def test_the_resolver_is_not_the_class_body
    resolver = UnionResolverBlock::CanalBridgeOpening.approval_resolver

    refute_nil resolver
    assert_equal true, UnionResolverBlock::CanalBridgeOpening.requires_approval?
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
