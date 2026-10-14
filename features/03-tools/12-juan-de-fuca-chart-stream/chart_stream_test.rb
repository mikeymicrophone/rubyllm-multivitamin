# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "yaml"
require_relative "chart_stream"

class ChartStreamTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/chart_stream.yml", __dir__)

  def test_the_stream_keeps_argument_strings_and_the_callback_keeps_a_hash
    skip "cassette pending live recording" unless File.exist?(CASSETTE)

    result = nil
    Multivitamin::Cassettes.play(__dir__, "chart_stream") do
      result = JuanDeFucaChartStream::NoticeStream.conduct
    end

    assert_equal result.speech, result.pieces.join
    assert_includes result.speech, "18465"
    assert_includes result.speech, "0.2"
    assert_equal %i[system user assistant tool assistant], result.roles

    assert result.fragments.any? { |_name, arguments| arguments.is_a?(String) }
    assert result.fragments.all? { |_name, arguments| arguments.is_a?(String) }
    assert result.fragments.any? { |name, arguments| arguments == "" && name }
    assert_kind_of Hash, result.tool_arguments
    joined = result.fragments.map { |_name, arguments| arguments.to_s }.join
    assert_equal result.tool_arguments, JSON.parse(joined)

    assert_kind_of Hash, result.callback_result
    assert_equal "18465", result.callback_result.fetch("chart")
    assert_kind_of String, result.tool_content
    assert_equal result.callback_result, JSON.parse(result.tool_content)
    refute_kind_of Hash, result.tool_content

    assert result.progress_notes.any? { |note| note.include?("1842") }
    assert result.tool_call_id
    assert_includes result.tool_arguments.values.map(&:to_s), "1842"
    assert_equal [result.tool_content], result.linked_content

    bodies = YAML.load_file(CASSETTE).fetch("http_interactions").map { |interaction| interaction.dig("request", "body", "string") }
    assert_includes bodies.fetch(0), '"stream":true'
    assert_includes bodies.fetch(0), "chart_notice"
    refute_includes bodies.fetch(0), "18465"
    refute_includes bodies.fetch(1), '"tool_choice"'
    assert_includes bodies.fetch(1), "18465"
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette pending live recording" unless File.exist?(CASSETTE)

    cassette = File.read(CASSETTE)

    refute_match(/sk-or-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
