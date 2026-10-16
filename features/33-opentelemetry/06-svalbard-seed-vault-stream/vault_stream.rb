# frozen_string_literal: true

# OpenTelemetry · 06 · Svalbard seed vault stream
#
# Teaches:
# - A block on ask streams an OpenRouter brief with thinking disabled.
# - filter_map selects spoken chunks; callbacks inspect the live span context.
# - The completed span carries stream=true and the final usage.

require "json"
require_relative "../../../support/tracing"

module SvalbardSeedVaultStream
  def self.conduct
    Multivitamin::Runtime.configure(provider: :openrouter)
    Multivitamin::Tracing.capture do |exporter|
      pieces = []
      observations = []
      chat = RubyLLM.chat(model: Multivitamin::Models::CHAT, provider: :openrouter, assume_model_exists: true)
      chat.with_thinking(false)
      chat.with_instructions("Brief the Svalbard seed-vault transfer from the card only. Name Ingrid, chamber 2, and 10:10.")
      message = chat.ask("Transfer card: Ingrid moves the sealed barley tray to chamber 2 at 10:10. Give the spoken handover.") do |chunk|
        pieces << chunk.content
        observations << [exporter.finished_spans.size, OpenTelemetry::Trace.current_span.context.valid?]
      end
      { message: message, speech: pieces.filter_map { |piece| piece unless piece.to_s.empty? }.join, observations: observations }
    end
  end
end

if $PROGRAM_NAME == __FILE__
  capture = Multivitamin::Cassettes.play(__dir__, "vault_stream") do
    SvalbardSeedVaultStream.conduct
  end
  puts capture.value.inspect
  puts capture.spans.map(&:name)
end
