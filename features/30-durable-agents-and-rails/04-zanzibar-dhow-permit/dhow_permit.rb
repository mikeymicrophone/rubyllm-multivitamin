# frozen_string_literal: true

# Durable agents and Rails · 04 · Zanzibar dhow permit
#
# Teaches:
# - requires_approval parks a job; another record approves by ID before CompleteJob.
# - Ruby idiom: Fluent configuration and a lambda decision boundary.

require_relative "../../../support/durable"

module ZanzibarDhowPermit
  class WatchLog < ActiveRecord::Base
    self.table_name = "zanzibar_dhow_permit_watch_logs"
    acts_as_chat messages: :watch_entries,
                 message_class: "ZanzibarDhowPermit::WatchEntry",
                 messages_foreign_key: :zanzibar_dhow_permit_watch_log_id
  end

  class WatchEntry < ActiveRecord::Base
    self.table_name = "zanzibar_dhow_permit_watch_entries"
    acts_as_message chat: :watch_log,
                    chat_class: "ZanzibarDhowPermit::WatchLog",
                    chat_foreign_key: :zanzibar_dhow_permit_watch_log_id
  end

  def self.prepare!(**options)
    Multivitamin::Durable.prepare!(chat_class: WatchLog, message_class: WatchEntry, **options)
  end

  class IssuePermit < RubyLLM::Tool
    description "Issue a Stone Town dhow loading permit after harbour approval"
    requires_approval
    parameters do
      string :dhow, description: "Dhow name on the harbour board"
    end
    def self.tool_name = "issue_permit"
    def execute(dhow:) = "Stone Town permit ZNZ-41 issued to #{dhow} for 17:40."
  end

  class HarbourKeeper < RubyLLM::Agent
    chat_model WatchLog
    model Multivitamin::Models::OPENAI_CHAT, provider: :openai
    tools IssuePermit
    instructions "You keep Stone Town harbour permits in Zanzibar. Call issue_permit for Mwangaza, then state its permit number and time."
  end

  class CompleteJob < Multivitamin::DurableJob
    def perform(watch_id)
      HarbourKeeper.find(watch_id).complete
    end
  end

  def self.conduct
    prepare!
    watch = HarbourKeeper.create!.with_temperature(0.1)
    watch.ask_later("Mwangaza is ready at the dhow steps. Request the 17:40 permit.")
    CompleteJob.perform_later(watch.id)
    Multivitamin::Durable.drain
    parked = HarbourKeeper.find(watch.id)
    pending = parked.pending_approvals.first
    before_roles = parked.watch_entries.map { _1.role.to_sym }
    authorize = ->(watch_id, call_id) do
      WatchLog.find(watch_id).approve(call_id)
      CompleteJob.perform_later(watch_id)
    end
    authorize.call(watch.id, pending.tool_call_id)
    Multivitamin::Durable.drain
    { parked: before_roles, approval: pending.reload.approval,
      brief: HarbourKeeper.find(watch.id).watch_entries.last.content,
      results: RubyLLM::ActiveRecord::ToolCall.where.not(result_id: nil).count }
  end
end

if $PROGRAM_NAME == __FILE__
  Multivitamin::Cassettes.play(__dir__, "dhow_permit") do
    puts ZanzibarDhowPermit.conduct.inspect
  end
end
