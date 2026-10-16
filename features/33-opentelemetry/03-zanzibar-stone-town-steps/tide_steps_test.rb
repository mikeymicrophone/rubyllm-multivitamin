# frozen_string_literal: true

require "minitest/autorun"
require_relative "tide_steps"

class ZanzibarStoneTownStepsTest < Minitest::Test
  def test_tide_steps_trace
    capture = Multivitamin::Cassettes.play(__dir__, "tide_steps") do
      ZanzibarStoneTownSteps.conduct
    end

    assert_equal %i[user assistant tool], capture.value.fetch(:roles)
    assert_equal 45, capture.value.dig(:card, "clearance_cm")
    step = capture.spans.find { |span| span.name == "ruby_llm.workflow_step Read landing card" }
    tool = capture.spans.find { |span| span.name == "execute_tool landing_tide" }
    chat = capture.spans.find { |span| span.name == "chat gpt-4.1-mini" }
    refute_nil step
    refute_nil tool
    assert_equal :internal, tool.kind
    assert_equal step.span_id, tool.parent_span_id
    assert_equal step.span_id, chat.parent_span_id
    assert_equal "function", tool.attributes.fetch("gen_ai.tool.type")
    refute_empty tool.attributes.fetch("gen_ai.tool.call.id")
    assert_equal 1, capture.spans.count { |span| span.name.start_with?("chat ") }
    refute capture.spans.any? { |span| span.name.include?("step_rope") }
  end

  def test_cassette_has_only_filtered_credentials
    cassette = File.binread(File.expand_path("cassettes/tide_steps.yml", __dir__))
    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
