# frozen_string_literal: true

require "minitest/autorun"
require_relative "quarry_stop"

class RapaNuiQuarryStopTest < Minitest::Test
  def test_quarry_stop_is_consumed_before_http
    result = Multivitamin::Cassettes.play(__dir__, "quarry_stop") { RapaNuiQuarryStop.conduct }

    assert result.requested
    assert result.interrupted
    assert result.consumed
    assert_equal %i[system user], result.roles
  end
end
