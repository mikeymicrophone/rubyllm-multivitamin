# frozen_string_literal: true

# Durable agents and Rails · 12 · Rapa Nui quarry stop
#
# Teaches:
# - cancelled is a persisted request consumed by the next worker checkpoint; no HTTP is needed.
# - Ruby idiom: Immutable Data result and local state transitions.

require_relative "../../../support/durable"

module RapaNuiQuarryStop
  class WatchLog < ActiveRecord::Base
    self.table_name = "rapa_nui_quarry_stop_watch_logs"
    acts_as_chat messages: :watch_entries,
                 message_class: "RapaNuiQuarryStop::WatchEntry",
                 messages_foreign_key: :rapa_nui_quarry_stop_watch_log_id
  end

  class WatchEntry < ActiveRecord::Base
    self.table_name = "rapa_nui_quarry_stop_watch_entries"
    acts_as_message chat: :watch_log,
                    chat_class: "RapaNuiQuarryStop::WatchLog",
                    chat_foreign_key: :rapa_nui_quarry_stop_watch_log_id
  end

  def self.prepare!(**options)
    Multivitamin::Durable.prepare!(chat_class: WatchLog, message_class: WatchEntry, **options)
  end

  StopReceipt = Data.define(:requested, :interrupted, :consumed, :roles)

  class QuarryKeeper < RubyLLM::Agent
    chat_model WatchLog
    model Multivitamin::Models::OPENAI_CHAT, provider: :openai
    instructions "You keep the Rano Raraku quarry path on Rapa Nui. Respect the ranger's stop request."
  end

  def self.conduct
    prepare!
    watch = QuarryKeeper.create!
    watch.ask_later("Rano Raraku ranger card: halt the east quarry survey pending a rockfall inspection.")
    WatchLog.find(watch.id).cancel
    requested = WatchLog.find(watch.id).cancelled?
    worker = QuarryKeeper.find(watch.id)
    interrupted = false
    begin
      worker.step
    rescue RubyLLM::CancelledError
      interrupted = true
    end
    StopReceipt.new(requested: requested, interrupted: interrupted,
                    consumed: !WatchLog.find(watch.id).cancelled?,
                    roles: WatchLog.find(watch.id).watch_entries.map { _1.role.to_sym })
  end
end

if $PROGRAM_NAME == __FILE__
  Multivitamin::Cassettes.play(__dir__, "quarry_stop") do
    puts RapaNuiQuarryStop.conduct.inspect
  end
end
