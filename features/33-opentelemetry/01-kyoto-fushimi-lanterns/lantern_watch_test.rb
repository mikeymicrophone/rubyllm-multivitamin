# frozen_string_literal: true

require "minitest/autorun"
require_relative "lantern_watch"

class KyotoFushimiLanternsTest < Minitest::Test
  def test_lantern_watch_trace
    previous_provider = OpenTelemetry.tracer_provider
    capture = Multivitamin::Cassettes.play(__dir__, "lantern_watch") do
      KyotoFushimiLanterns::LanternWatch.conduct
    end

    assert_includes capture.value.content, "Haruka"
    assert_includes capture.value.content, "06:40"
    assert_equal ["chat gpt-4.1-mini"], capture.spans.map(&:name)
    assert_equal :client, capture.spans.first.kind
    assert_equal "ruby_llm", capture.spans.first.instrumentation_scope.name
    assert_equal RubyLLM::VERSION, capture.spans.first.instrumentation_scope.version
    assert_same previous_provider, OpenTelemetry.tracer_provider
    refute OpenTelemetry::Trace.current_span.context.valid?
  end

  def test_cassette_has_only_filtered_credentials
    cassette = File.binread(File.expand_path("cassettes/lantern_watch.yml", __dir__))
    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
