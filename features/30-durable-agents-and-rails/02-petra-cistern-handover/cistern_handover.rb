# frozen_string_literal: true

# Durable agents and Rails · 02 · Petra cistern handover
#
# Teaches:
# - Agent.find restores configuration and resumes staged history by ID.
# - Ruby idiom: Customized Data record, module functions, and then.

require_relative "../../../support/durable"

module PetraCisternHandover
  class WatchLog < ActiveRecord::Base
    self.table_name = "petra_cistern_handover_watch_logs"
    acts_as_chat messages: :watch_entries,
                 message_class: "PetraCisternHandover::WatchEntry",
                 messages_foreign_key: :petra_cistern_handover_watch_log_id
  end

  class WatchEntry < ActiveRecord::Base
    self.table_name = "petra_cistern_handover_watch_entries"
    acts_as_message chat: :watch_log,
                    chat_class: "PetraCisternHandover::WatchLog",
                    chat_foreign_key: :petra_cistern_handover_watch_log_id
  end

  def self.prepare!(**options)
    Multivitamin::Durable.prepare!(chat_class: WatchLog, message_class: WatchEntry, **options)
  end

  CisternCard = Data.define(:custodian, :cistern, :litres) do
    def question = "Petra card: #{custodian} logged #{litres} litres in #{cistern}. Repeat the custodian, cistern and litres."
  end

  class WaterKeeper < RubyLLM::Agent
    chat_model WatchLog
    model Multivitamin::Models::OPENAI_CHAT, provider: :openai
    instructions "You keep Petra's cistern handover. Use only the card and answer in one sentence. Keep names and quantities."
  end

  module Handover
    module_function

    def stage(card)
      WaterKeeper.create!.tap { |watch| watch.ask_later(card.question) }.id
    end

    def resume(watch_id)
      WaterKeeper.find(watch_id).then do |watch|
        opening = watch.complete
        watch.ask_later("Which cistern did Salma log? Keep the cistern name.")
        { opening: opening.content, follow_up: WaterKeeper.find(watch_id).complete.content,
          system_rows: WatchLog.find(watch_id).watch_entries.where(role: :system).count }
      end
    end
  end

  def self.conduct
    prepare!
    CisternCard.new(custodian: "Salma", cistern: "Siq inlet", litres: 840)
               .then { Handover.stage(_1) }.then { Handover.resume(_1) }
  end
end

if $PROGRAM_NAME == __FILE__
  Multivitamin::Cassettes.play(__dir__, "cistern_handover") do
    puts PetraCisternHandover.conduct.inspect
  end
end
