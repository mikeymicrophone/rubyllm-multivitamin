# frozen_string_literal: true

# OpenTelemetry · 10 · Ilulissat icefjord index
#
# Teaches:
# - An enumerator and lazy pipeline prepare a batch embedding; numbered blocks tally operations.
# - A refinement names a span operation without changing String globally.
# - An in-memory exporter supports snapshots and reset; embeddings carry dimension and input usage.

require "json"
require_relative "../../../support/tracing"

module IlulissatIcefjordIndex
  module OperationLabels
    refine String do
      def operation_label = split(" ", 2).first
    end
  end
  using OperationLabels

  NOTICES = ["Sermermiut boardwalk: stay behind the rope.", "Icefjord Centre: evening talk at 19:00.", "Old harbour: kayak briefing at 08:15."].freeze

  def self.conduct
    Multivitamin::Runtime.configure(provider: :openai)
    Multivitamin::Tracing.capture do |exporter|
      notices = NOTICES.each.lazy.map(&:strip).reject(&:empty?).force
      embedding = RubyLLM.embed(notices, model: Multivitamin::Models::OPENAI_EMBEDDING, provider: :openai, dimensions: 3)
      snapshot = exporter.finished_spans
      counts = snapshot.group_by { |span| span.name.operation_label }.transform_values { _1.size }
      exporter.reset
      { vectors: embedding.vectors, tokens: embedding.tokens, snapshot: snapshot, counts: counts, after_reset: exporter.finished_spans.size }
    end
  end
end

if $PROGRAM_NAME == __FILE__
  capture = Multivitamin::Cassettes.play(__dir__, "icefjord_index") do
    IlulissatIcefjordIndex.conduct
  end
  puts capture.value.inspect
  puts capture.spans.map(&:name)
end
