# frozen_string_literal: true

# Durable agents and Rails · 09 · Venice tide gate
#
# Teaches:
# - Raw record find has history; Agent.find also restores the tools needed to execute it.
# - Ruby idiom: Bound method passed with &, map, and runtime rehydration.

require_relative "../../../support/durable"

module VeniceTideGate
  class WatchLog < ActiveRecord::Base
    self.table_name = "venice_tide_gate_watch_logs"
    acts_as_chat messages: :watch_entries,
                 message_class: "VeniceTideGate::WatchEntry",
                 messages_foreign_key: :venice_tide_gate_watch_log_id
  end

  class WatchEntry < ActiveRecord::Base
    self.table_name = "venice_tide_gate_watch_entries"
    acts_as_message chat: :watch_log,
                    chat_class: "VeniceTideGate::WatchLog",
                    chat_foreign_key: :venice_tide_gate_watch_log_id
  end

  def self.prepare!(**options)
    Multivitamin::Durable.prepare!(chat_class: WatchLog, message_class: WatchEntry, **options)
  end

  class ReadStaff < RubyLLM::Tool
    description "Read the posted tide staff at Venice's Arsenale gate"
    def self.tool_name = "read_staff"
    def execute = "Arsenale staff: 82 cm; service gate stays shut until 10:40."
  end

  class TideKeeper < RubyLLM::Agent
    chat_model WatchLog
    model Multivitamin::Models::OPENAI_CHAT, provider: :openai
    tools ReadStaff
    instructions "You keep Venice's Arsenale gate. Call read_staff, then report its centimetres and gate time."
  end

  def self.tool_name(call) = call.name

  def self.conduct
    prepare!
    watch = TideKeeper.create!
    watch.ask_later("Arsenale service card: read the tide staff before admitting the restoration barge.")
    watch.step
    raw = WatchLog.find(watch.id)
    bare_names = raw.tools.keys
    configured = TideKeeper.find(watch.id)
    pending_names = configured.watch_entries.last.ruby_llm_tool_calls.map(&method(:tool_name))
    answer = configured.complete
    { bare_names: bare_names, restored_names: configured.tools.keys.map(&:to_s),
      pending_names: pending_names, brief: answer.content, same_id: configured.id == raw.id }
  end
end

if $PROGRAM_NAME == __FILE__
  Multivitamin::Cassettes.play(__dir__, "tide_gate") do
    puts VeniceTideGate.conduct.inspect
  end
end
