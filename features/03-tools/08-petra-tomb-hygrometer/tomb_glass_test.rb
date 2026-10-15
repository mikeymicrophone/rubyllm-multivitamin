# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "tomb_glass"

class TombGlassTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/tomb_glass.yml", __dir__)

  def test_a_raised_glass_is_not_sent_back_as_a_tool_message
    result = nil
    Multivitamin::Cassettes.play(__dir__, "tomb_glass") do
      result = PetraTombHygrometer::GlassCheck.conduct
    end

    assert_instance_of PetraTombHygrometer::TombGlassUnseated, result.error
    assert_match(/off the board/, result.error.message)
    assert_match(/Treasury/i, result.error.message)
    assert_equal %i[system user assistant], result.roles
    assert result.tool_called
    refute_includes result.roles, :tool

    request = YAML.load_file(CASSETTE).dig("http_interactions", 0, "request", "body", "string")
    assert_includes request, "tomb_hygrometer"
    assert_equal 1, YAML.load_file(CASSETTE).fetch("http_interactions").size
  end

  def test_execute_raises_before_it_can_return_a_reading
    tool = PetraTombHygrometer::TombHygrometer.new

    error = assert_raises(PetraTombHygrometer::TombGlassUnseated) do
      tool.execute(tomb: "Treasury")
    end
    assert_includes error.message, "Treasury"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
    refute_includes cassette, "Bearer sk-"
  end
end
