# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "gate_listen"

class BremertonMcpListenChangeTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/gate_listen.yml", __dir__)

  def test_listen_hears_the_sill_card_join_the_desk
    result = nil
    Multivitamin::Cassettes.play(__dir__, "gate_listen") do
      result = BremertonMcpListen::GateListen.conduct
    end

    refute_includes result.names_before, "dry_dock_sill"
    assert_includes result.names_after, "dry_dock_sill"
    assert_includes result.heard, :tools
    assert_includes result.tool_content, "18.4 ft"
    assert_includes result.answer, "Skookum"
    assert_includes result.answer, "18.4"
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
