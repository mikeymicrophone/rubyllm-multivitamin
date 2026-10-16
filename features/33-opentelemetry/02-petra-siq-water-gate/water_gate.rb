# frozen_string_literal: true

# OpenTelemetry · 02 · Petra Siq water gate
#
# Teaches:
# - A customized immutable Data record totals token buckets with zip and sum.
# - A fluent chat sets temperature and output cap, visible on the client span.
# - Requested and response model IDs differ; reported zero cache counts stay present.

require "json"
require_relative "../../../support/tracing"

module PetraSiqWaterGate
  GateBrief = Data.define(:message, :roles) do
    def input_buckets
      %i[uncached cache_read cache_write].zip(
        [message.tokens.input, message.tokens.cache_read, message.tokens.cache_write]
      ).to_h
    end
    def billed_input = input_buckets.values.compact.sum
  end

  module_function

  def conduct
    Multivitamin::Runtime.configure(provider: :openai)
    Multivitamin::Tracing.capture do
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
        .with_instructions("Brief Petra's Siq gate from the inspection card only; name Salma, the hold, and the opening time.")
        .with_temperature(0.1)
        .with_max_output_tokens(160)
        .then do |chat|
          message = chat.ask("Siq channel: Salma clears the east intake at 07:20. Hold the visitor gate until 07:35. State the opening instruction.")
          GateBrief.new(message: message, roles: chat.messages.map(&:role))
        end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  capture = Multivitamin::Cassettes.play(__dir__, "water_gate") do
    PetraSiqWaterGate.conduct
  end
  puts capture.value.inspect
  puts capture.spans.map(&:name)
end
