# frozen_string_literal: true

# Rails integration · 02 · Varanasi zari-spool log
#
# Teaches:
# - acts_as_message persists roles, including the assistant.
# - add_message appends a weaver note without a provider call.
# - Reloading the log from the database keeps the same roles and rack.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/active_record"

module VaranasiZariSpoolLog
  class SpoolLog < ActiveRecord::Base
    self.table_name = "varanasi_spool_logs"
    acts_as_chat messages: :spool_entries,
                 message_class: "VaranasiZariSpoolLog::SpoolEntry",
                 messages_foreign_key: :varanasi_spool_log_id
  end

  class SpoolEntry < ActiveRecord::Base
    self.table_name = "varanasi_spool_entries"
    acts_as_message chat: :spool_log,
                    chat_class: "VaranasiZariSpoolLog::SpoolLog",
                    chat_foreign_key: :varanasi_spool_log_id
  end

  class SpoolKeeper
    INSTRUCTIONS = <<~TEXT.strip
      You are the zari keeper in a Banarasi weaving household in Alaipura, Varanasi.
      Answer in one short sentence from the spool card only.
      Name rack 3 and the 24-strand gold zari.
    TEXT

    KEEPER_NOTE = <<~TEXT.strip
      Spool card from Wednesday 14 October 2026 at the Mishra loom house, Alaipura, Varanasi.
      Weavers Service Centre: https://handlooms.nic.in/
      Rack 3 holds the 24-strand gold zari. The spare silver stays on rack 1.
    TEXT

    RACK_QUESTION = "Which rack holds the 24-strand gold zari, and should the spare silver move?"

    Result = Struct.new(
      :brief,
      :roles,
      :reloaded_roles,
      :reloaded_rack,
      :assistant_content,
      keyword_init: true
    )

    def self.conduct
      log = open_log
      log.with_instructions(INSTRUCTIONS)
      log.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(log, provider: :openai)
      log.add_message(role: :user, content: KEEPER_NOTE)
      brief = log.ask(RACK_QUESTION)

      reloaded = SpoolLog.find(log.id)
      Result.new(
        brief: brief.content,
        roles: log.spool_entries.map { |entry| entry.role.to_sym },
        reloaded_roles: reloaded.spool_entries.map { |entry| entry.role.to_sym },
        reloaded_rack: reloaded.spool_entries.find { |entry| entry.role.to_s == "assistant" }&.content,
        assistant_content: log.spool_entries.find { |entry| entry.role.to_s == "assistant" }&.content
      )
    end

    def self.open_log
      choice = boot
      SpoolLog.create!(**choice)
    end

    def self.boot
      Multivitamin::ActiveRecordBoot.prepare!(
        chat_table: :varanasi_spool_logs,
        message_table: :varanasi_spool_entries,
        message_foreign_key: :varanasi_spool_log_id
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
  Multivitamin::Cassettes.play(__dir__, "spool_log") do
    result = VaranasiZariSpoolLog::SpoolKeeper.conduct
  end

  puts result.brief
end
