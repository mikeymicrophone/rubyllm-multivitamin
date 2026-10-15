# frozen_string_literal: true

# Rails integration · 02 · New Dungeness lens log
#
# Teaches:
# - acts_as_message persists roles, including the assistant.
# - add_message appends a keeper note without a provider call.
# - Reloading the log from the database keeps the same roles and drawer.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/active_record"

module NewDungenessLensLog
  class LensLog < ActiveRecord::Base
    self.table_name = "new_dungeness_lens_logs"
    acts_as_chat messages: :lens_entries,
                 message_class: "NewDungenessLensLog::LensEntry",
                 messages_foreign_key: :new_dungeness_lens_log_id
  end

  class LensEntry < ActiveRecord::Base
    self.table_name = "new_dungeness_lens_entries"
    acts_as_message chat: :lens_log,
                    chat_class: "NewDungenessLensLog::LensLog",
                    chat_foreign_key: :new_dungeness_lens_log_id
  end

  class LensKeeper
    INSTRUCTIONS = <<~TEXT.strip
      You are the lens keeper at New Dungeness Light Station.
      Answer in one short sentence from the cabinet card only.
      Name drawer 3 and the 24-inch bullseye.
    TEXT

    KEEPER_NOTE = <<~TEXT.strip
      Cabinet card from Wednesday 14 October 2026 at New Dungeness.
      Station page: https://www.nps.gov/places/new-dungeness-light-station.htm
      Drawer 3 holds the 24-inch bullseye. The spare prisms stay in drawer 1.
    TEXT

    DRAWER_QUESTION = "Which drawer holds the 24-inch bullseye, and should the spare prisms move?"

    Result = Struct.new(
      :brief,
      :roles,
      :reloaded_roles,
      :reloaded_drawer,
      :assistant_content,
      keyword_init: true
    )

    def self.conduct
      log = open_log
      log.with_instructions(INSTRUCTIONS)
      log.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(log, provider: :openai)
      log.add_message(role: :user, content: KEEPER_NOTE)
      brief = log.ask(DRAWER_QUESTION)

      reloaded = LensLog.find(log.id)
      Result.new(
        brief: brief.content,
        roles: log.lens_entries.map { |entry| entry.role.to_sym },
        reloaded_roles: reloaded.lens_entries.map { |entry| entry.role.to_sym },
        reloaded_drawer: reloaded.lens_entries.find { |entry| entry.role.to_s == "assistant" }&.content,
        assistant_content: log.lens_entries.find { |entry| entry.role.to_s == "assistant" }&.content
      )
    end

    def self.open_log
      choice = boot
      LensLog.create!(**choice)
    end

    def self.boot
      Multivitamin::ActiveRecordBoot.prepare!(
        chat_table: :new_dungeness_lens_logs,
        message_table: :new_dungeness_lens_entries,
        message_foreign_key: :new_dungeness_lens_log_id
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
  Multivitamin::Cassettes.play(__dir__, "lens_log") do
    result = NewDungenessLensLog::LensKeeper.conduct
  end

  puts result.brief
end
