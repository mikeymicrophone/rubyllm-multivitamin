# frozen_string_literal: true

require_relative "runtime"
require "opentelemetry/sdk"

module Multivitamin
  # The application owns the SDK. Each capture installs a fresh, synchronous
  # exporter so replay needs neither an OTLP endpoint nor an export thread.
  # This helper owns RubyLLM's tracing subscription for the capture's duration.
  module Tracing
    Capture = Data.define(:value, :spans)

    module_function

    def capture(enable: true)
      previous_provider = OpenTelemetry.tracer_provider
      provider = OpenTelemetry::SDK::Trace::TracerProvider.new(
        sampler: OpenTelemetry::SDK::Trace::Samplers::ALWAYS_ON
      )
      exporter = OpenTelemetry::SDK::Trace::Export::InMemorySpanExporter.new
      provider.add_span_processor(OpenTelemetry::SDK::Trace::Export::SimpleSpanProcessor.new(exporter))
      OpenTelemetry.tracer_provider = provider
      RubyLLM::OpenTelemetry.enable if enable
      value = yield exporter
      provider.force_flush
      Capture.new(value: value, spans: exporter.finished_spans)
    ensure
      RubyLLM::OpenTelemetry.disable
      OpenTelemetry.tracer_provider = previous_provider if previous_provider
      provider&.shutdown
    end
  end
end
