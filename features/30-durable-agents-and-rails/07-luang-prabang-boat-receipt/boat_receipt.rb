# frozen_string_literal: true

# Durable agents and Rails · 07 · Luang Prabang boat receipt
#
# Teaches:
# - At-least-once tool execution needs a durable business key; a lost result must not duplicate the receipt.
# - Ruby idiom: Database uniqueness, find_or_create_by!, and retry after failure.

require_relative "../../../support/durable"

module LuangPrabangBoatReceipt
  class WatchLog < ActiveRecord::Base
    self.table_name = "luang_prabang_boat_receipt_watch_logs"
    acts_as_chat messages: :watch_entries,
                 message_class: "LuangPrabangBoatReceipt::WatchEntry",
                 messages_foreign_key: :luang_prabang_boat_receipt_watch_log_id
  end

  class WatchEntry < ActiveRecord::Base
    self.table_name = "luang_prabang_boat_receipt_watch_entries"
    acts_as_message chat: :watch_log,
                    chat_class: "LuangPrabangBoatReceipt::WatchLog",
                    chat_foreign_key: :luang_prabang_boat_receipt_watch_log_id
  end

  def self.prepare!(**options)
    Multivitamin::Durable.prepare!(chat_class: WatchLog, message_class: WatchEntry, **options)
  end

  class CargoReceipt < ActiveRecord::Base
    self.table_name = "luang_prabang_cargo_receipts"
  end

  class LostReceiptResult < StandardError; end

  class ReceiveSacks < RubyLLM::Tool
    description "File the rice sack receipt at Luang Prabang's Mekong landing"
    parameters do
      string :manifest, description: "Unique manifest reference"
      integer :sacks, description: "Rice sack count"
    end
    def self.tool_name = "receive_sacks"

    def execute(manifest:, sacks:)
      receipt = CargoReceipt.find_or_create_by!(manifest: manifest) { _1.sacks = sacks }
      raise LostReceiptResult, "Worker lost the tool result after filing" if CargoReceipt.where(id: receipt.id, attempts: 0).update_all(attempts: 1) == 1

      receipt.increment!(:attempts)
      "Receipt #{receipt.manifest}: #{receipt.sacks} sacks filed once."
    end
  end

  class LandingKeeper < RubyLLM::Agent
    chat_model WatchLog
    model Multivitamin::Models::OPENAI_CHAT, provider: :openai
    tools ReceiveSacks
    instructions "You keep Luang Prabang's landing ledger. Call receive_sacks for manifest LP-86 with 18 sacks, then report the receipt."
  end

  def self.conduct
    prepare!
    ActiveRecord::Schema.define do
      create_table :luang_prabang_cargo_receipts do |column|
        column.string :manifest, null: false
        column.integer :sacks, null: false
        column.integer :attempts, default: 0, null: false
        column.index :manifest, unique: true
      end
    end
    CargoReceipt.reset_column_information
    watch = LandingKeeper.create!
    watch.ask_later("Receive LP-86 at the Mekong steps: 18 sacks of rice.")
    watch.step
    lost = false
    begin
      LandingKeeper.find(watch.id).step
    rescue LostReceiptResult
      lost = true
    end
    answer = LandingKeeper.find(watch.id).complete
    { lost: lost, receipts: CargoReceipt.count, sacks: CargoReceipt.sum(:sacks),
      attempts: CargoReceipt.first.attempts, brief: answer.content,
      results: WatchLog.find(watch.id).watch_entries.where(role: :tool).count }
  end
end

if $PROGRAM_NAME == __FILE__
  Multivitamin::Cassettes.play(__dir__, "boat_receipt") do
    puts LuangPrabangBoatReceipt.conduct.inspect
  end
end
