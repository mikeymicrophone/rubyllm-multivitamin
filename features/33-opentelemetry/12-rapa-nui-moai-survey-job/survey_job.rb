# frozen_string_literal: true

# OpenTelemetry · 12 · Rapa Nui moai survey job
#
# Teaches:
# - An immutable job envelope survives a JSON round trip.
# - TraceContext inject/extract explicitly propagates an application-created thread.
# - The worker workflow joins its dispatch parent; RubyLLM does not propagate arbitrary jobs automatically.

require "json"
require_relative "../../../support/tracing"

module RapaNuiMoaiSurveyJob
  SurveyJob = Data.define(:carrier, :card)

  def self.conduct
    Multivitamin::Runtime.configure(provider: :openai)
    Multivitamin::Tracing.capture do
      propagator = OpenTelemetry::Trace::Propagation::TraceContext.text_map_propagator
      OpenTelemetry.tracer_provider.tracer("moai-survey").in_span("Dispatch survey") do
        carrier = {}
        propagator.inject(carrier)
        envelope = JSON.generate(carrier: carrier, card: "Rano Raraku survey: Hina inspects the east path at 09:45; keep visitors behind the rope. Brief the team.")
        Thread.new(envelope) do |serialized|
          payload = JSON.parse(serialized)
          job = SurveyJob.new(carrier: payload.fetch("carrier"), card: payload.fetch("card"))
          parent = propagator.extract(job.carrier)
          OpenTelemetry::Context.with_current(parent) do
            RubyLLM.workflow("Survey briefing", id: "survey-briefing") do
              RubyLLM.chat(model: Multivitamin::Models::OPENAI_CHAT, provider: :openai)
                .with_instructions("Brief the Rapa Nui survey card only. Name Hina, 09:45, and the visitor rope.")
                .ask(job.card)
            end
          end
        end.value
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  capture = Multivitamin::Cassettes.play(__dir__, "survey_job") do
    RapaNuiMoaiSurveyJob.conduct
  end
  puts capture.value.inspect
  puts capture.spans.map(&:name)
end
