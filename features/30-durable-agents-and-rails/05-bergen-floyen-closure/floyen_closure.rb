# frozen_string_literal: true

# Durable agents and Rails · 05 · Bergen Fløyen closure
#
# Teaches:
# - A web-process denial persists; the resumed worker returns a denial result without running the tool.
# - Ruby idiom: Decision table and case/in destructuring.

require_relative "../../../support/durable"

module BergenFloyenClosure
  class WatchLog < ActiveRecord::Base
    self.table_name = "bergen_floyen_closure_watch_logs"
    acts_as_chat messages: :watch_entries,
                 message_class: "BergenFloyenClosure::WatchEntry",
                 messages_foreign_key: :bergen_floyen_closure_watch_log_id
  end

  class WatchEntry < ActiveRecord::Base
    self.table_name = "bergen_floyen_closure_watch_entries"
    acts_as_message chat: :watch_log,
                    chat_class: "BergenFloyenClosure::WatchLog",
                    chat_foreign_key: :bergen_floyen_closure_watch_log_id
  end

  def self.prepare!(**options)
    Multivitamin::Durable.prepare!(chat_class: WatchLog, message_class: WatchEntry, **options)
  end

  class LiftClosure < RubyLLM::Tool
    description "Lift the Fløyen upper path closure after a ranger decision"
    requires_approval
    def self.tool_name = "lift_closure"
    def execute = raise("The Bergen closure must stay in force")
  end

  class Ranger < RubyLLM::Agent
    chat_model WatchLog
    model Multivitamin::Models::OPENAI_CHAT, provider: :openai
    tools LiftClosure
    instructions "You keep Bergen's Fløyen path notice. Request lift_closure once. If denied, say the upper path remains closed for wind."
  end

  class ClosureJob < Multivitamin::DurableJob
    def perform(watch_id) = Ranger.find(watch_id).complete
  end

  def self.conduct
    prepare!
    watch = Ranger.create!
    watch.ask("Fløyen board: upper path closed for wind. Ask the ranger to lift the closure.")
    decisions = [{ watch_id: watch.id, decision: :deny }]
    decisions.each do |decision|
      case decision
      in { watch_id:, decision: :deny }
        web_watch = WatchLog.find(watch_id)
        web_watch.deny(web_watch.watch_entries.last.ruby_llm_tool_calls.first.tool_call_id)
        ClosureJob.perform_later(watch_id)
      end
    end
    Multivitamin::Durable.drain
    found = Ranger.find(watch.id)
    { approval: RubyLLM::ActiveRecord::ToolCall.first.approval,
      tool_result: found.watch_entries.find_by(role: :tool).content, brief: found.watch_entries.last.content }
  end
end

if $PROGRAM_NAME == __FILE__
  Multivitamin::Cassettes.play(__dir__, "floyen_closure") do
    puts BergenFloyenClosure.conduct.inspect
  end
end
