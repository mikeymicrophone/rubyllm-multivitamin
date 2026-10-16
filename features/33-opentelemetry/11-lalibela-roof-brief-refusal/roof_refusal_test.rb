# frozen_string_literal: true

require "minitest/autorun"
require_relative "roof_refusal"

class LalibelaRoofBriefRefusalTest < Minitest::Test
  def test_roof_refusal_trace
    capture = Multivitamin::Cassettes.play(__dir__, "roof_refusal") do
      LalibelaRoofBriefRefusal.conduct
    end

    assert_instance_of RubyLLM::BadRequestError, capture.value
    assert_equal 3, capture.spans.size
    capture.spans.each do |span|
      assert_equal "RubyLLM::BadRequestError", span.attributes.fetch("error.type")
      assert_equal OpenTelemetry::Trace::Status::ERROR, span.status.code
      assert_empty span.events.to_a
      refute_includes span.status.description.to_s, "temperature"
      refute_includes span.attributes.to_s, "Dawit"
    end
    refute OpenTelemetry::Trace.current_span.context.valid?
  end

  def test_cassette_has_only_filtered_credentials
    cassette = File.binread(File.expand_path("cassettes/roof_refusal.yml", __dir__))
    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
