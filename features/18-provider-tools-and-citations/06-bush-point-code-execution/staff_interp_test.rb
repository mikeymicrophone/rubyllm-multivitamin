# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "staff_interp"

class ProviderToolsBushPointCodeExecutionTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/staff_interp.yml", __dir__)

  def test_the_staff_runs_code_and_posts_the_interpolated_height
    result = nil
    Multivitamin::Cassettes.play(__dir__, "staff_interp") do
      result = BushPointCodeExecution::StaffInterp.conduct
    end

    assert_match(/Bush Point/i, result.brief)
    assert_match(/Alden/i, result.brief)
    assert_match(/5\.99/, result.brief)
    assert_includes result.call_types, "code_interpreter_call"
    assert_nil result.server_tool_use
    assert_equal %i[system user assistant], result.roles
    assert_operator result.cost, :>, 0

    request = request_bodies.fetch(0)
    assert_includes request, '"type":"code_interpreter"'
    assert_includes request, '"container":{"type":"auto"}'
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map do |interaction|
      interaction.dig("request", "body", "string").to_s
    end
  end
end
