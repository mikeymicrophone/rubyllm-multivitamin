# frozen_string_literal: true

# OpenTelemetry · 01 · Kyoto Fushimi lantern watch
#
# Teaches:
# - An instance owns a chat created before enable.
# - Configure the SDK before enabling; repeated enable is harmless.
# - A real ask exports one span and leaves the answer intact.

require "json"
require_relative "../../../support/tracing"

module KyotoFushimiLanterns
  class LanternWatch
    def initialize
      Multivitamin::Runtime.configure(provider: :openai)
      @chat = RubyLLM.chat(model: Multivitamin::Models::OPENAI_CHAT, provider: :openai)
      @chat.with_instructions("Brief the Fushimi Inari lantern relief from the card only. Name the keeper, lantern, and time.")
    end

    def conduct
      Multivitamin::Tracing.capture(enable: false) do
        RubyLLM::OpenTelemetry.enable
        RubyLLM::OpenTelemetry.enable
        @chat.ask("Kyoto lantern card: Haruka replaces the cracked shade at lantern F-17 at 06:40. Brief the relief.")
      end
    end

    def self.conduct = new.conduct
  end
end

if $PROGRAM_NAME == __FILE__
  capture = Multivitamin::Cassettes.play(__dir__, "lantern_watch") do
    KyotoFushimiLanterns::LanternWatch.conduct
  end
  puts capture.value.inspect
  puts capture.spans.map(&:name)
end
