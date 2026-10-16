# frozen_string_literal: true

# OpenTelemetry · 11 · Lalibela roof brief refusal
#
# Teaches:
# - A provider exception passes through workflow and step boundaries.
# - error.type and error status are exported without exception text or events.
# - Rescue outside the workflow preserves the failed tree and returns a typed refusal.

require "json"
require_relative "../../../support/tracing"

module LalibelaRoofBriefRefusal
  def self.conduct
    Multivitamin::Runtime.configure(provider: :openai)
    Multivitamin::Tracing.capture do
      begin
        RubyLLM.workflow("Roof inspection brief", id: "roof-inspection") do |workflow|
          workflow.step("Read roof card") do
            RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
              .with_temperature(9)
              .ask("Lalibela roof card: Dawit closes the north scaffold until 14:20. Brief the conservators.")
          end
        end
      rescue RubyLLM::BadRequestError => refusal
        refusal
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  capture = Multivitamin::Cassettes.play(__dir__, "roof_refusal") do
    LalibelaRoofBriefRefusal.conduct
  end
  puts capture.value.inspect
  puts capture.spans.map(&:name)
end
