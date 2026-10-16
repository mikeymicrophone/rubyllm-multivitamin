# frozen_string_literal: true

require "minitest/autorun"
require_relative "beehive_panel"

class LjubljanaBeehivePanelRootsTest < Minitest::Test
  def test_the_host_file_wins_and_the_engine_fills_the_gap
    result = nil
    Multivitamin::Cassettes.play(__dir__, "beehive_panel") do
      result = LjubljanaBeehivePanel::BeehivePanel.conduct
    end

    assert_includes result.host_card, "Host panel"
    refute_includes result.host_card, "Engine panel"
    assert_includes result.engine_only, "Engine-only card"
    assert_instance_of RubyLLM::PromptNotFoundError, result.without_engine_error
    refute File.exist?(File.expand_path("cassettes/beehive_panel.yml", __dir__))
  end
end
