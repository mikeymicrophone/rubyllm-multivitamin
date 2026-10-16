# frozen_string_literal: true

# Durable agents and Rails · 13 · Marrakesh medina handover
#
# Teaches:
# - Capstone: bounded turns, persisted approval, idempotent issue, and a fresh-worker handover.
# - Ruby idiom: Scoped refinement, proc stop policy, bounded jobs, and find patterns.

require_relative "../../../support/durable"

module MarrakeshMedinaHandover
  class WatchLog < ActiveRecord::Base
    self.table_name = "marrakesh_medina_handover_watch_logs"
    acts_as_chat messages: :watch_entries,
                 message_class: "MarrakeshMedinaHandover::WatchEntry",
                 messages_foreign_key: :marrakesh_medina_handover_watch_log_id
  end

  class WatchEntry < ActiveRecord::Base
    self.table_name = "marrakesh_medina_handover_watch_entries"
    acts_as_message chat: :watch_log,
                    chat_class: "MarrakeshMedinaHandover::WatchLog",
                    chat_foreign_key: :marrakesh_medina_handover_watch_log_id
  end

  def self.prepare!(**options)
    Multivitamin::Durable.prepare!(chat_class: WatchLog, message_class: WatchEntry, **options)
  end

  module NoticeText
    refine String do
      def notice_line = split.join(" ")
    end
  end
  using NoticeText

  class DeliveryPass < ActiveRecord::Base
    self.table_name = "marrakesh_delivery_passes"
  end

  class GateWindow < RubyLLM::Tool
    description "Read the medina delivery window posted at Bab Doukkala"
    def self.tool_name = "gate_window"
    def execute = "Bab Doukkala delivery window: 06:45; one handcart per booking."
  end

  class IssuePass < RubyLLM::Tool
    description "Issue a medina delivery pass for a unique handcart booking"
    requires_approval
    parameters do
      string :booking, description: "Unique handcart booking code"
    end
    def self.tool_name = "issue_pass"
    def execute(booking:)
      pass = DeliveryPass.find_or_create_by!(booking: booking)
      "Medina pass #{pass.booking}: Bab Doukkala, 06:45, Amina's handcart."
    end
  end

  class MedinaKeeper < RubyLLM::Agent
    chat_model WatchLog
    model Multivitamin::Models::OPENAI_CHAT, provider: :openai
    tools GateWindow, IssuePass
    instructions "You keep Marrakesh's medina delivery watch. Call gate_window and issue_pass for booking MD-73 together, then state Amina's gate and time from the pass."
  end

  class TurnJob < Multivitamin::DurableJob
    STOP = proc { |watch| watch.complete? || watch.waiting? }

    def perform(watch_id, remaining)
      return if remaining <= 0
      watch = MedinaKeeper.find(watch_id)
      watch.step
      self.class.perform_later(watch_id, remaining - 1) unless STOP.call(watch) || remaining == 1
    end
  end

  def self.conduct
    prepare!
    ActiveRecord::Schema.define do
      create_table :marrakesh_delivery_passes do |column|
        column.string :booking, null: false
        column.index :booking, unique: true
      end
    end
    DeliveryPass.reset_column_information
    watch = MedinaKeeper.create!
    watch.ask_later("Medina booking MD-73: request Amina's handcart pass before dawn.")
    TurnJob.perform_later(watch.id, 1)
    first_jobs = Multivitamin::Durable.drain
    limited = MedinaKeeper.find(watch.id)
    budget_exhausted = !limited.complete? && !limited.waiting?
    queued_after_cap = Multivitamin::Durable.queued
    TurnJob.perform_later(watch.id, 2)
    parking_jobs = Multivitamin::Durable.drain
    reviewer = MedinaKeeper.find(watch.id)
    parked = reviewer.waiting?
    passes_before = DeliveryPass.count
    reviewer.approve(reviewer.pending_approvals.first)
    TurnJob.perform_later(watch.id, 2)
    resumed_jobs = Multivitamin::Durable.drain
    found = MedinaKeeper.find(watch.id)
    transcript = found.watch_entries.map { [_1.role, _1.content] }
    handover = case transcript
               in [*, ["tool", String], ["assistant", String => brief]] then brief.notice_line
               else raise "Medina handover is incomplete"
               end
    { first_jobs: first_jobs, parking_jobs: parking_jobs, budget_exhausted: budget_exhausted,
      queued_after_cap: queued_after_cap, resumed_jobs: resumed_jobs, parked: parked, passes_before: passes_before,
      passes_after: DeliveryPass.count, complete: found.complete?, handover: handover,
      system_rows: found.watch_entries.where(role: :system).count }
  end
end

if $PROGRAM_NAME == __FILE__
  Multivitamin::Cassettes.play(__dir__, "medina_handover") do
    puts MarrakeshMedinaHandover.conduct.inspect
  end
end
