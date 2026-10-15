# frozen_string_literal: true

# Tool approval and loop control · 08 · Skokomish pending ask raises
#
# Teaches:
# - ask while a protected call is still pending raises
#   PendingToolCallsError. That class inherits StandardError, not
#   RubyLLM::Error.
# - The error names the unanswered tool. approve then complete finishes
#   the round.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module SkokomishPendingAsk
  class EstuaryLatch < RubyLLM::Tool
    description "Opens the Skokomish estuary tide gate. Needs the river tender's latch."

    def self.tool_name
      "estuary_latch"
    end

    requires_approval

    def self.reset!
      @opened = false
    end

    def self.opened?
      @opened == true
    end

    def execute
      self.class.instance_variable_set(:@opened, true)
      "Skokomish estuary gate opened. Ebb 2.2 kn under the Highway 101 twin bridges."
    end
  end

  class RiverTender
    INSTRUCTIONS = <<~TEXT.strip
      You are the river tender at the Skokomish estuary.
      Call estuary_latch once.
      After it runs, answer in one short sentence that names the ebb the
      latch returns and the Highway 101 twin bridges.
    TEXT

    GATE_QUESTION = <<~TEXT.strip
      Thursday 15 October 2026, ebb watch at the Skokomish estuary.
      Tide station: https://tidesandcurrents.noaa.gov/stationhome.html?id=9446969
      Open the estuary gate for the outgoing current.
    TEXT

    SECOND_QUESTION = "The Annas Bay skiff asks again: is the estuary gate open?"

    Result = Struct.new(
      :error_class,
      :error_message,
      :error_superclass,
      :caught_as_provider_error,
      :opened,
      :answer,
      :roles,
      keyword_init: true
    )

    def self.conduct
      configure
      EstuaryLatch.reset!

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_tools(EstuaryLatch)
      chat.with_tool_options(choice: EstuaryLatch)

      chat.ask(GATE_QUESTION)

      error_class = nil
      error_message = nil
      error_superclass = nil
      caught_as_provider_error = false
      begin
        chat.ask(SECOND_QUESTION)
      rescue RubyLLM::Error
        caught_as_provider_error = true
      rescue RubyLLM::PendingToolCallsError => error
        error_class = error.class.name
        error_message = error.message
        error_superclass = error.class.superclass.name
      end

      pending = chat.pending_approvals.first
      chat.approve(pending) if pending
      answer = chat.complete

      Result.new(
        error_class: error_class,
        error_message: error_message,
        error_superclass: error_superclass,
        caught_as_provider_error: caught_as_provider_error,
        opened: EstuaryLatch.opened?,
        answer: answer&.content,
        roles: chat.messages.map(&:role)
      )
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 180
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "estuary_latch") do
    result = SkokomishPendingAsk::RiverTender.conduct
  end

  puts result.error_class
  puts result.answer
end
