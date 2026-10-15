# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "watch_capstone"

class AdmiraltyInletMcpCapstoneTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/watch_capstone.yml", __dir__)

  def test_the_watch_uses_the_desk_then_the_latch_card
    result = nil
    Multivitamin::Cassettes.play(__dir__, "watch_capstone") do
      result = AdmiraltyInletMcpCapstone::WatchCapstone.conduct
    end

    assert_equal %w[admiralty_posted_tide_board admiralty_posted_horn_card].sort, result.tool_names.sort
    assert_equal "watch://admiralty-inlet/lens-latch.md", result.latch_uri
    assert_includes result.tool_contents.join("\n"), "10:12"
    assert_includes result.tool_contents.join("\n"), "3 seconds"
    assert_includes result.tide_answer, "Alden"
    assert_includes result.tide_answer, "10:12"
    assert_includes result.horn_answer, "3"
    assert_includes result.roles, :tool
    assert_operator result.roles.count(:tool), :>=, 2
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
