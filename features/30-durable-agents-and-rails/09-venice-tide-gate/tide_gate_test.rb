# frozen_string_literal: true

require "minitest/autorun"
require_relative "tide_gate"

class VeniceTideGateTest < Minitest::Test
  def test_tide_keeper_restores_runtime_tools
    result = Multivitamin::Cassettes.play(__dir__, "tide_gate") { VeniceTideGate.conduct }

    assert_empty result.fetch(:bare_names)
    assert_equal ["read_staff"], result.fetch(:restored_names)
    assert_equal ["read_staff"], result.fetch(:pending_names)
    assert result.fetch(:same_id)
    assert_includes result.fetch(:brief), "82 cm"
    assert_includes result.fetch(:brief), "10:40"
  end

  def test_cassette_has_no_live_key
    cassette = File.binread(File.join(__dir__, "cassettes/tide_gate.yml"))
    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
