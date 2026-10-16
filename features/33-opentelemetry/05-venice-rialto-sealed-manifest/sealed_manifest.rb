# frozen_string_literal: true

# OpenTelemetry · 05 · Venice Rialto sealed manifest
#
# Teaches:
# - RubyLLM.context isolates an instrumenter and provider settings.
# - A lambda observes chat events without replacing the tracing subscriber.
# - Workflow metadata, prompts, headers, provider options, and replies stay out of exported spans.

require "json"
require_relative "../../../support/tracing"

module VeniceRialtoSealedManifest
  PRIVATE_SEAL = "RIALTO-SEALED-73"

  ManifestEvents = Data.define(:on_chat) do
    def instrument(name, payload)
      on_chat.call(name) if name == "chat.ruby_llm" && payload[:chat]
      yield(payload) if block_given?
    end
  end

  def self.conduct
    observed = []
    observer = ManifestEvents.new(on_chat: ->(name) { observed << name })
    context = RubyLLM.context do |config|
      Multivitamin::Runtime.apply(config, provider: :openai)
      config.instrumenter = observer
    end
    Multivitamin::Tracing.capture do
      RubyLLM.workflow("Receiving brief", id: "receiving-brief", metadata: { seal: PRIVATE_SEAL }) do
        message = context.chat(model: Multivitamin::Models::OPENAI_CHAT, provider: :openai)
          .with_instructions("You are the Rialto receiving clerk. Repeat the sealed reference and the unloading time from the manifest.")
          .with_headers("X-Receiving-Seal" => PRIVATE_SEAL)
          .with_provider_options(metadata: { receiving_seal: PRIVATE_SEAL })
          .ask("Manifest #{PRIVATE_SEAL}: Lucia unloads the artichoke crates at 05:50. Read back the reference and time.")
        { message: message, observed: observed }
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  capture = Multivitamin::Cassettes.play(__dir__, "sealed_manifest") do
    VeniceRialtoSealedManifest.conduct
  end
  puts capture.value.inspect
  puts capture.spans.map(&:name)
end
