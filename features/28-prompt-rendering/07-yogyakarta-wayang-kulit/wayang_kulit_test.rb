# frozen_string_literal: true

require "minitest/autorun"
require_relative "wayang_kulit"

class YogyakartaWayangKulitAgentTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/wayang_kulit.yml", __dir__)

  def test_the_dalang_starts_without_a_system_turn
    result = nil
    Multivitamin::Cassettes.play(__dir__, "wayang_kulit") do
      result = YogyakartaWayangKulit::WayangKulit.conduct
    end

    assert_equal :user, result.first_role
    refute_includes result.roles, :system
    assert_includes result.brief, "Wayan"
    assert_includes result.brief, "19:30"
    assert_equal "YogyakartaWayangKulit::PuppetClerk", result.agent_class
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
