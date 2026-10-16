# frozen_string_literal: true

# Rails integration · 10 · Gaborone diamond-tray empty
#
# Teaches:
# - An assistant row may have empty content. Streaming inserts that row
#   before any text arrives.
# - A presence validation on content rejects that insert.
# - The tray log leaves the validation off so ask can persist.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/active_record"

module GaboroneDiamondTray
  class TrayLog < ActiveRecord::Base
    self.table_name = "gaborone_tray_logs"
    acts_as_chat messages: :tray_entries,
                 message_class: "GaboroneDiamondTray::TrayEntry",
                 messages_foreign_key: :gaborone_tray_log_id
  end

  class TrayEntry < ActiveRecord::Base
    self.table_name = "gaborone_tray_entries"
    acts_as_message chat: :tray_log,
                    chat_class: "GaboroneDiamondTray::TrayLog",
                    chat_foreign_key: :gaborone_tray_log_id
  end

  class TrayEntryWithPresence < ActiveRecord::Base
    self.table_name = "gaborone_tray_entries"
    belongs_to :tray_log, class_name: "GaboroneDiamondTray::TrayLog",
                          foreign_key: :gaborone_tray_log_id
    validates :content, presence: true
  end

  class TrayClerk
    INSTRUCTIONS = <<~TEXT.strip
      You are the sort clerk at a cutting loft in Gaborone.
      Answer in one short sentence from the tray card only.
      Name parcel 4 and the 14:30 sort.
    TEXT

    TRAY_QUESTION = <<~TEXT.strip
      Tray card for Wednesday 14 October 2026 at the Gaborone loft.
      Debswana page: https://www.debswana.com/
      Parcel 4 sorts at 14:30. The velvet is clear.
      When does the parcel sort?
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
      empty = TrayEntry.create!(tray_log: log, role: :assistant, content: "")
      presence_error = nil
      begin
        TrayEntryWithPresence.create!(tray_log: log, role: :assistant, content: "")
      rescue ActiveRecord::RecordInvalid => error
        presence_error = error
      end

      log.with_instructions(INSTRUCTIONS)
      log.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(log, provider: :openai)
      brief = log.ask(TRAY_QUESTION)

      Result.new(
        brief: brief.content,
        empty_persisted: empty.persisted?,
        empty_content: empty.content,
        presence_error: presence_error,
        roles: log.tray_entries.map { |entry| entry.role.to_sym }
      )
    end

    def self.open_log
      choice = boot
      TrayLog.create!(**choice)
    end

    def self.boot
      Multivitamin::ActiveRecordBoot.prepare!(
        chat_table: :gaborone_tray_logs,
        message_table: :gaborone_tray_entries,
        message_foreign_key: :gaborone_tray_log_id
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
  Multivitamin::Cassettes.play(__dir__, "empty_tray") do
    result = GaboroneDiamondTray::TrayClerk.conduct
  end

  puts result.brief
end
