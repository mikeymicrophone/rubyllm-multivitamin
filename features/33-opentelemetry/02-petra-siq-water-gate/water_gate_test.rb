# frozen_string_literal: true

require "minitest/autorun"
require_relative "water_gate"

class PetraSiqWaterGateTest < Minitest::Test
  def test_water_gate_trace
    capture = Multivitamin::Cassettes.play(__dir__, "water_gate") do
      PetraSiqWaterGate.conduct
    end

    brief = capture.value
    span = capture.spans.fetch(0)
    assert brief.frozen?
    assert_includes brief.message.content, "07:35"
    assert_equal %i[system user assistant], brief.roles
    assert_equal :client, span.kind
    assert_equal "openai", span.attributes.fetch("gen_ai.provider.name")
    assert_equal "gpt-4.1-mini", span.attributes.fetch("gen_ai.request.model")
    assert_equal brief.message.model, span.attributes.fetch("gen_ai.response.model")
    assert_equal 0.1, span.attributes.fetch("gen_ai.request.temperature")
    assert_equal 160, span.attributes.fetch("gen_ai.request.max_tokens")
    assert_equal brief.billed_input, span.attributes.fetch("gen_ai.usage.input_tokens")
    assert_equal brief.message.tokens.output, span.attributes.fetch("gen_ai.usage.output_tokens")
    assert_equal brief.message.tokens.cache_read, span.attributes.fetch("gen_ai.usage.cache_read.input_tokens")
    assert_equal 0, span.attributes.fetch("gen_ai.usage.cache_read.input_tokens")
  end

  def test_cassette_has_only_filtered_credentials
    cassette = File.binread(File.expand_path("cassettes/water_gate.yml", __dir__))
    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
