# frozen_string_literal: true

# Structured output · 09 · Bremerton dry dock gate
#
# Teaches:
# - with_schema sticks for later asks until you change it.
# - with_schema(nil) returns the chat to prose.
# - A later with_schema installs a different schema on the same chat.

require "json"
require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module BremertonDryDockGate
  class GateState < Schematist::Schema
    title "gate_state"
    description "Dry dock gate at the Port of Bremerton"

    string :gate, enum: %w[open shut], description: "Whether the gate is open or shut"
    number :sill_ft, description: "Water over the sill in feet"
  end

  class CrewNote < Schematist::Schema
    title "crew_note"
    description "Note for the dock crew after the prose turn"

    string :watch, enum: %w[morning afternoon], description: "Which watch the note is for"
    string :note, description: "One sentence. Say whether the gate is shut."
  end

  class GateLog
    INSTRUCTIONS = <<~TEXT.strip
      You are the dry dock clerk at the Port of Bremerton.
      When a schema is set, fill only that schema from the conversation.
      When no schema is set, answer in one prose sentence and do not use JSON.
    TEXT

    GATE_QUESTION = <<~TEXT.strip
      Wednesday 14 October 2026, morning, Port of Bremerton dry dock.
      Gate office: https://www.portofbremerton.org/
      The gate is shut. Water over the sill is 18.4 ft.
      Record the gate state.
    TEXT

    PROSE_QUESTION = "Can the crew walk the sill this morning? One sentence."

    NOTE_QUESTION = "Now write the crew note for the afternoon watch. The gate is still shut."

    Result = Struct.new(:gate, :prose, :note, :roles, :finish, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)

      chat.with_schema(GateState)
      gate = chat.ask(GATE_QUESTION)

      chat.with_schema(nil)
      prose = chat.ask(PROSE_QUESTION)

      chat.with_schema(CrewNote)
      note = chat.ask(NOTE_QUESTION)

      Result.new(
        gate: gate.parsed,
        prose: prose.content,
        note: note.parsed,
        roles: chat.messages.map(&:role),
        finish: note.finish_reason
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
  Multivitamin::Cassettes.play(__dir__, "gate_state") do
    result = BremertonDryDockGate::GateLog.conduct
  end

  puts JSON.generate(result.gate)
  puts result.prose
  puts JSON.generate(result.note)
end
