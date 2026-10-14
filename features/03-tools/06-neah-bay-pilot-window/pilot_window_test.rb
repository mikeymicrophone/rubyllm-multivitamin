# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "pilot_window"

class PilotWindowTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/pilot_window.yml", __dir__)

  def test_the_cleared_tide_tool_is_not_on_the_request
    result = nil
    Multivitamin::Cassettes.play(__dir__, "pilot_window") do
      result = NeahBayPilotWindow::LadderWindow.conduct
    end

    assert_equal [:pilot_ladder_window], result.registered
    assert_includes result.tool_content, "09:10"
    assert_includes result.tool_content, "11:40"
    assert_includes result.tool_content, "starboard"
    assert_includes result.answer, "09:10"
    assert_equal %i[system user assistant tool assistant], result.roles

    request = YAML.load_file(CASSETTE).dig("http_interactions", 0, "request", "body", "string")
    assert_includes request, "pilot_ladder_window"
    refute_includes request, "makah_tide_window"
    refute_includes request, "05:48"
  end

  def test_with_tools_nil_replaces_the_set
    Multivitamin::Cassettes.prepare_key!

    chat = NeahBayPilotWindow::LadderWindow.open_desk

    assert_equal [:pilot_ladder_window], chat.tools.keys
    refute_respond_to chat, :with_tool
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
    refute_includes cassette, "Bearer sk-"
  end
end
