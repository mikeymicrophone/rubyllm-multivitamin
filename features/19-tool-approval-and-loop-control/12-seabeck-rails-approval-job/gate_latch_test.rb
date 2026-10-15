# frozen_string_literal: true

require "minitest/autorun"
require_relative "gate_latch"

class GateLatchTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/gate_latch.yml", __dir__)

  def test_the_harbor_master_approves_from_a_found_log
    result = nil
    Multivitamin::Cassettes.play(__dir__, "gate_latch") do
      result = SeabeckRailsApprovalJob::GateJob.conduct
    end

    assert result.awaiting
    assert_nil result.approval_before
    assert_nil result.opened_before
    assert result.same_id
    assert_equal "approved", result.approval_after
    assert_equal "Elwha", result.opened_after
    assert_includes result.answer, "Elwha"
    assert_includes result.answer, "1.6"
    assert_equal 1, result.tool_call_count
    assert_equal %i[system user assistant tool assistant], result.roles
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
