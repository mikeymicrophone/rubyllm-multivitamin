# frozen_string_literal: true

# OpenTelemetry · 07 · Cape Town cableway fallback
#
# Teaches:
# - A proc receives before_fallback; method(:name) is passed with &.
# - A cross-provider fallback creates a new model span.
# - The failed attempt retains error.type while the spare returns the brief.

require "json"
require_relative "../../../support/tracing"

module CapeTownCablewayFallback
  class CablewayDesk
    def initialize
      @fallbacks = []
    end

    def note_fallback(fallback) = @fallbacks << fallback.error.class.name

    def conduct
      Multivitamin::Runtime.configure(provider: :openrouter)
      Multivitamin::Runtime.configure(provider: :openai)
      Multivitamin::Tracing.capture do
        RubyLLM.workflow("Cableway dispatch", id: "cableway-dispatch") do
          chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openrouter))
          chat.with_instructions("Brief Table Mountain's cableway from the board only. Name Thandi, the wind hold, and 11:30.")
          chat.with_fallbacks(RubyLLM.models.find(Multivitamin::Models::OPENAI_CHAT, provider: :openai))
          forward = proc { |fallback| note_fallback(fallback) }
          chat.before_fallback(&forward)
          message = chat.ask("Cableway board: Thandi holds departures for wind until the 11:30 review. State the hold.")
          { message: message, fallback_errors: @fallbacks.map(&method(:error_label)) }
        end
      end
    end

    def error_label(name) = name.delete_prefix("RubyLLM::")
    def self.conduct = new.conduct
  end
end

if $PROGRAM_NAME == __FILE__
  capture = Multivitamin::Cassettes.play(__dir__, "cableway_fallback") do
    CapeTownCablewayFallback::CablewayDesk.conduct
  end
  puts capture.value.inspect
  puts capture.spans.map(&:name)
end
