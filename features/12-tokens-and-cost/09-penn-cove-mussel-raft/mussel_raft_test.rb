# frozen_string_literal: true

require "minitest/autorun"
require_relative "mussel_raft"

class PennCoveMusselRaftTenantTalliesTest < Minitest::Test
  def test_two_tenants_keep_separate_tallies_and_aggregate_sums_them
    result = nil
    Multivitamin::Cassettes.play(__dir__, "mussel_raft") do
      result = PennCoveMusselRaft::MusselRaft.conduct
    end

    assert_includes result.raft_brief, "42"
    assert_includes result.raft_brief, "PC-4"
    assert_includes result.dock_brief, "28"
    assert_match(/Keystone/, result.dock_brief)

    assert_equal [PennCoveMusselRaft::MusselRaft::RAFT], result.raft_owner
    assert_equal [PennCoveMusselRaft::MusselRaft::DOCK], result.dock_owner
    refute_equal result.raft_owner, result.dock_owner

    assert_equal 0, result.raft_cost
    assert_equal 0, result.dock_cost
    assert_equal 0, result.aggregated_cost
    assert_operator result.raft_input, :>, 0
    assert_operator result.dock_input, :>, 0
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/mussel_raft.yml", __dir__))

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
