# frozen_string_literal: true

require "minitest/autorun"
require_relative "alhambra_approval"

class GranadaAlhambraApprovalTest < Minitest::Test
  def test_alhambra_approval_research_flow
    before = WebMock::RequestRegistry.instance.requested_signatures.hash.values.sum
    refusals = GranadaAlhambraApproval.conduct
    assert_equal before, WebMock::RequestRegistry.instance.requested_signatures.hash.values.sum
    assert_match(/MCP does not support: require_approval/, refusals.fetch(:approval))
    assert_match(/only support agent_config and service_tier: max_output_tokens/, refusals.fetch(:generation))
  end
end
