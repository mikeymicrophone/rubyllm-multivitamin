# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "loom_desk"

class LoomDeskTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/loom_desk.yml", __dir__)

  def test_the_clerk_picks_the_cloth_length
    result = nil
    Multivitamin::Cassettes.play(__dir__, "loom_desk") do
      result = AccraKenteLoom::LoomDesk.conduct
    end

    assert_includes result.registered, :reed_sett
    assert_includes result.registered, :cloth_length
    assert_includes result.tool_contents.join("\n"), "54 cm"
    refute_includes result.tool_contents.join("\n"), "11.2"
    assert_includes result.answer, "54"
    assert_includes result.roles, :tool
    assert_equal :assistant, result.roles.last

    request = YAML.load_file(CASSETTE).dig("http_interactions", 0, "request", "body", "string")
    assert_includes request, "reed_sett"
    assert_includes request, "cloth_length"
    assert_includes request, '"tool_choice":"required"'
    refute_includes request, "54"
  end

  def test_classes_and_stateful_instances_share_one_registration
    Multivitamin::Cassettes.prepare_key!

    chat = AccraKenteLoom::LoomDesk.open_desk

    assert_equal %i[reed_sett cloth_length], chat.tools.keys
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
    refute_includes cassette, "Bearer sk-"
  end
end
