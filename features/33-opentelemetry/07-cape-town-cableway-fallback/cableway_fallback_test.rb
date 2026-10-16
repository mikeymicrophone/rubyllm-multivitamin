# frozen_string_literal: true

require "minitest/autorun"
require_relative "cableway_fallback"

class CapeTownCablewayFallbackTest < Minitest::Test
  def test_cableway_fallback_trace
    capture = Multivitamin::Cassettes.play(__dir__, "cableway_fallback") do
      CapeTownCablewayFallback::CablewayDesk.conduct
    end

    assert_includes capture.value.fetch(:message).content, "11:30"
    assert_equal ["RateLimitError"], capture.value.fetch(:fallback_errors)
    attempts = capture.spans.select { |span| span.kind == :client }
    assert_equal 2, attempts.size
    failed, spare = attempts
    assert_equal "openrouter", failed.attributes.fetch("gen_ai.provider.name")
    assert_equal "RubyLLM::RateLimitError", failed.attributes.fetch("error.type")
    assert_equal OpenTelemetry::Trace::Status::ERROR, failed.status.code
    assert_equal "openai", spare.attributes.fetch("gen_ai.provider.name")
    refute spare.attributes.key?("error.type")
    assert_equal failed.parent_span_id, spare.parent_span_id
    assert_equal 1, capture.spans.map(&:trace_id).uniq.size
  end

  def test_cassette_has_only_filtered_credentials
    cassette = File.binread(File.expand_path("cassettes/cableway_fallback.yml", __dir__))
    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
