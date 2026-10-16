# frozen_string_literal: true

# Structured output · 09 · Chengdu panda enclosure
#
# Teaches:
# - with_schema sticks for later asks until you change it.
# - with_schema(nil) returns the chat to prose.
# - A later with_schema installs a different schema on the same chat.
# - A table of schema/question pairs drives the three turns with map.

require "json"
require_relative "../../../support/runtime"

module ChengduPandaGate
  class GateState < Schematist::Schema
    title "gate_state"
    description "Panda enclosure gate at the Chengdu Research Base"

    string :gate, enum: %w[open shut], description: "Whether the gate is open or shut"
    number :moat_cm, description: "Water in the moat in centimetres"
  end

  class CrewNote < Schematist::Schema
    title "crew_note"
    description "Note for the keepers after the prose turn"

    string :watch, enum: %w[morning afternoon], description: "Which watch the note is for"
    string :note, description: "One sentence. Say whether the gate is shut."
  end

  class GateLog
    INSTRUCTIONS = <<~TEXT.strip
      You are the enclosure clerk at the Chengdu Research Base of Giant Panda Breeding.
      When a schema is set, fill only that schema from the conversation.
      When no schema is set, answer in one prose sentence and do not use JSON.
    TEXT

    GATE_QUESTION = <<~TEXT.strip
      Wednesday 14 October 2026, morning, Chengdu panda enclosure.
      Base office: https://www.panda.org.cn/
      The gate is shut. Water in the moat is 18.4 cm.
      Record the gate state.
    TEXT

    PROSE_QUESTION = "Can the keepers walk the moat this morning? One sentence."

    NOTE_QUESTION = "Now write the crew note for the afternoon watch. The gate is still shut."

    Result = Struct.new(:gate, :prose, :note, :roles, :finish, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)

      gate, prose, note = [
        [GateState, GATE_QUESTION],
        [nil, PROSE_QUESTION],
        [CrewNote, NOTE_QUESTION]
      ].map { |schema, question| chat.with_schema(schema).ask(question) }

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

    def self.configure = Multivitamin::Runtime.configure(provider: :openai, timeout: 180)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "gate_state") do
    ChengduPandaGate::GateLog.conduct
  end

  puts JSON.generate(result.gate)
  puts result.prose
  puts JSON.generate(result.note)
end
