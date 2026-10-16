# frozen_string_literal: true

require "minitest/autorun"
require_relative "terrace_drains"

class MachuPicchuTerraceDrainsTest < Minitest::Test
  def test_terrace_drains_trace
    capture = Multivitamin::Cassettes.play(__dir__, "terrace_drains") do
      MachuPicchuTerraceDrains.conduct
    end

    assert_equal({ "Upper terrace" => 6, "Lower terrace" => 4 }, capture.value)
    root = capture.spans.find { |span| span.name == "invoke_workflow Terrace drainage" }
    assert_equal :internal, root.kind
    assert_equal 5, capture.spans.size
    assert_equal 1, capture.spans.map(&:trace_id).uniq.size
    branches = capture.spans.select { |span| span.parent_span_id == root.span_id }
    assert_equal 2, branches.size
    outlets = capture.spans.select { |span| span.name.end_with?("Clear outlets") }
    assert_equal branches.map(&:span_id).sort, outlets.map(&:parent_span_id).sort
    assert capture.spans.all? { |span| span.start_timestamp <= span.end_timestamp }
  end

  def test_no_provider_fixture_is_needed
    refute File.exist?(File.expand_path("cassettes/terrace_drains.yml", __dir__))
  end

  def test_failed_inspection_restores_the_process_provider
    previous_provider = OpenTelemetry.tracer_provider
    assert_raises(ArgumentError) do
      Multivitamin::Tracing.capture do
        RubyLLM.workflow("Outlet inspection") { raise ArgumentError, "Missing outlet count" }
      end
    end
    assert_same previous_provider, OpenTelemetry.tracer_provider
    refute OpenTelemetry::Trace.current_span.context.valid?
    assert_equal 5, MachuPicchuTerraceDrains.conduct.spans.size
  end
end
