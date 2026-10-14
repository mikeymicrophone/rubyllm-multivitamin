# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "berth_desk"

class BerthDeskTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/berth_desk.yml", __dir__)

  def test_the_clerk_picks_the_berth_length
    result = nil
    Multivitamin::Cassettes.play(__dir__, "berth_desk") do
      result = FridayHarborBerthDesk::BerthDesk.conduct
    end

    assert_includes result.registered, :float_depth
    assert_includes result.registered, :berth_length
    assert_includes result.tool_contents.join("\n"), "54 ft"
    refute_includes result.tool_contents.join("\n"), "11.2"
    assert_includes result.answer, "54"
    assert_includes result.roles, :tool
    assert_equal :assistant, result.roles.last

    request = YAML.load_file(CASSETTE).dig("http_interactions", 0, "request", "body", "string")
    assert_includes request, "float_depth"
    assert_includes request, "berth_length"
    assert_includes request, '"tool_choice":"required"'
    refute_includes request, "54"
  end

  def test_a_second_with_tools_keeps_the_first_tool
    Multivitamin::Cassettes.prepare_key!

    chat = FridayHarborBerthDesk::BerthDesk.open_desk

    assert_equal %i[float_depth berth_length], chat.tools.keys
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
    refute_includes cassette, "Bearer sk-"
  end
end
