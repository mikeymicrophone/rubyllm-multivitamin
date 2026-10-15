# frozen_string_literal: true

# Rails integration · 01 · Point Wilson watch log
#
# Teaches:
# - acts_as_chat turns an ActiveRecord class into a persisted chat.
# - Chat.create!(model:, provider:) saves a row and a ruby_llm_models
#   association. ask persists the user and assistant turns.
# - messages.count and chat.model are read off the record.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/active_record"

module PointWilsonWatchLog
  class WatchLog < ActiveRecord::Base
    self.table_name = "point_wilson_watch_logs"
    acts_as_chat messages: :watch_entries,
                 message_class: "PointWilsonWatchLog::WatchEntry",
                 messages_foreign_key: :point_wilson_watch_log_id
  end

  class WatchEntry < ActiveRecord::Base
    self.table_name = "point_wilson_watch_entries"
    acts_as_message chat: :watch_log,
                    chat_class: "PointWilsonWatchLog::WatchLog",
                    chat_foreign_key: :point_wilson_watch_log_id
  end

  class TideClerk
    INSTRUCTIONS = <<~TEXT.strip
      You are the tide clerk at Point Wilson Light Station on Admiralty Inlet.
      Answer in one short sentence from the board only.
      Name the foghorn tender Alden and the clock 10:46.
    TEXT

    BOARD_QUESTION = <<~TEXT.strip
      Tide board posted for Wednesday 14 October 2026 at Point Wilson.
      Station page: https://tidesandcurrents.noaa.gov/stationhome.html?id=9444900
      Low water 06:42, 0.4 ft above MLLW.
      High water 12:18, 8.1 ft.
      Alden clears the kelp ledge at 10:46.
      When does Alden leave the float?
    TEXT

    Result = Struct.new(
      :brief,
      :entry_count,
      :roles,
      :model_id,
      :provider,
      :model_class,
      :persisted,
      keyword_init: true
    )

    def self.conduct
      log = open_log
      log.with_instructions(INSTRUCTIONS)
      log.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(log, provider: :openai)
      brief = log.ask(BOARD_QUESTION)

      Result.new(
        brief: brief.content,
        entry_count: log.watch_entries.count,
        roles: log.watch_entries.map { |entry| entry.role.to_sym },
        model_id: log.model_id,
        provider: log.provider,
        model_class: log.model.class.name,
        persisted: log.persisted?
      )
    end

    def self.open_log
      choice = boot
      WatchLog.create!(**choice)
    end

    def self.boot
      Multivitamin::ActiveRecordBoot.prepare!(
        chat_table: :point_wilson_watch_logs,
        message_table: :point_wilson_watch_entries,
        message_foreign_key: :point_wilson_watch_log_id
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
  Multivitamin::Cassettes.play(__dir__, "watch_log") do
    result = PointWilsonWatchLog::TideClerk.conduct
  end

  puts result.brief
  puts
  puts "#{result.entry_count} entries on #{result.model_id}"
end
