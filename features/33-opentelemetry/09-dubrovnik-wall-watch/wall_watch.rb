# frozen_string_literal: true

# OpenTelemetry · 09 · Dubrovnik wall watch
#
# Teaches:
# - An explicit watch loop crosses enable/disable boundaries.
# - disable stops new operations while an already running span finishes.
# - The application tracer remains usable; disable never shuts down its SDK.

require "json"
require_relative "../../../support/tracing"

module DubrovnikWallWatch
  def self.conduct
    Multivitamin::Tracing.capture do |exporter|
      walked = []
      RubyLLM.workflow("Wall inspection", id: "wall-inspection") do |workflow|
        %w[Pile Minčeta Ploče].each_with_index do |gate, index|
          RubyLLM::OpenTelemetry.disable if index == 1
          workflow.step("Walk sector") { walked << gate }
        end
      end
      finished_before_application = exporter.finished_spans.size
      OpenTelemetry.tracer_provider.tracer("wall-crew").in_span("Archive wall card") { walked.freeze }
      { walked: walked, finished_before_application: finished_before_application }
    end
  end
end

if $PROGRAM_NAME == __FILE__
  capture = Multivitamin::Cassettes.play(__dir__, "wall_watch") do
    DubrovnikWallWatch.conduct
  end
  puts capture.value.inspect
  puts capture.spans.map(&:name)
end
