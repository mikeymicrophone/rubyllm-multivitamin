# frozen_string_literal: true

# Rails integration · 10 · Bremerton empty gate
#
# Teaches:
# - An assistant row may have empty content. Streaming inserts that row
#   before any text arrives.
# - A presence validation on content rejects that insert.
# - The gate log leaves the validation off so ask can persist.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/active_record"

module BremertonEmptyGate
  class GateLog < ActiveRecord::Base
    self.table_name = "bremerton_gate_logs"
    acts_as_chat messages: :gate_entries,
                 message_class: "BremertonEmptyGate::GateEntry",
                 messages_foreign_key: :bremerton_gate_log_id
  end

  class GateEntry < ActiveRecord::Base
    self.table_name = "bremerton_gate_entries"
    acts_as_message chat: :gate_log,
                    chat_class: "BremertonEmptyGate::GateLog",
                    chat_foreign_key: :bremerton_gate_log_id
  end

  class GateEntryWithPresence < ActiveRecord::Base
    self.table_name = "bremerton_gate_entries"
    belongs_to :gate_log, class_name: "BremertonEmptyGate::GateLog",
                          foreign_key: :bremerton_gate_log_id
    validates :content, presence: true
  end

  class GateClerk
    INSTRUCTIONS = <<~TEXT.strip
      You are the dry-dock clerk at Puget Sound Naval Shipyard, Bremerton.
      Answer in one short sentence from the gate card only.
      Name caisson 4 and the 14:30 flood.
    TEXT

    GATE_QUESTION = <<~TEXT.strip
      Dry-dock gate card for Wednesday 14 October 2026 at Bremerton.
      Yard page: https://www.navsea.navy.mil/Home/Shipyards/PSNS-IMF/
      Caisson 4 floods at 14:30. The sill is clear.
      When does the caisson flood?
    TEXT

    Result = Struct.new(
      :brief,
      :empty_persisted,
      :empty_content,
      :presence_error,
      :roles,
      keyword_init: true
    )

    def self.conduct
      log = open_log
      empty = GateEntry.create!(gate_log: log, role: :assistant, content: "")
      presence_error = nil
      begin
        GateEntryWithPresence.create!(gate_log: log, role: :assistant, content: "")
      rescue ActiveRecord::RecordInvalid => error
        presence_error = error
      end

      log.with_instructions(INSTRUCTIONS)
      log.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(log, provider: :openai)
      brief = log.ask(GATE_QUESTION)

      Result.new(
        brief: brief.content,
        empty_persisted: empty.persisted?,
        empty_content: empty.content,
        presence_error: presence_error,
        roles: log.gate_entries.map { |entry| entry.role.to_sym }
      )
    end

    def self.open_log
      choice = boot
      GateLog.create!(**choice)
    end

    def self.boot
      Multivitamin::ActiveRecordBoot.prepare!(
        chat_table: :bremerton_gate_logs,
        message_table: :bremerton_gate_entries,
        message_foreign_key: :bremerton_gate_log_id
      )
      choice = Multivitamin::Models.chat(provider: :openai)
      Multivitamin::ActiveRecordBoot.seed_model(model_id: choice[:model], provider: choice[:provider])
      configure
      choice
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
  Multivitamin::Cassettes.play(__dir__, "empty_gate") do
    result = BremertonEmptyGate::GateClerk.conduct
  end

  puts result.brief
end
