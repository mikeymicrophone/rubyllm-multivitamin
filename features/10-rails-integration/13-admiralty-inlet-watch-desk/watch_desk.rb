# frozen_string_literal: true

# Rails integration · 13 · Admiralty Inlet watch desk
#
# Teaches:
# - A persisted watch desk keeps the chat, the messages, a tool call,
#   the model association, and a usage row on one log.
# - A second ask on the same record sends the earlier tool result back.
# - RubyLLM::ActiveRecord::Model and ToolCall stay the gem's records.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/active_record"

module AdmiraltyInletPersistedWatchDesk
  class WatchDeskLog < ActiveRecord::Base
    self.table_name = "admiralty_inlet_watch_desk_logs"
    acts_as_chat messages: :desk_entries,
                 message_class: "AdmiraltyInletPersistedWatchDesk::DeskEntry",
                 messages_foreign_key: :admiralty_inlet_watch_desk_log_id
  end

  class DeskEntry < ActiveRecord::Base
    self.table_name = "admiralty_inlet_desk_entries"
    acts_as_message chat: :watch_desk_log,
                    chat_class: "AdmiraltyInletPersistedWatchDesk::WatchDeskLog",
                    chat_foreign_key: :admiralty_inlet_watch_desk_log_id
  end

  class PostedTideBoard < RubyLLM::Tool
    description "Reads the Point Wilson tide board, including when Alden clears the kelp ledge"

    def self.tool_name
      "posted_tide_board"
    end

    def execute
      "Point Wilson tide board. Low water 07:05, 1.1 ft. Alden clears the kelp ledge at 10:12."
    end
  end

  class WatchClerk
    INSTRUCTIONS = <<~TEXT.strip
      You are the watch clerk at Point Wilson on Admiralty Inlet.
      Call posted_tide_board when the question needs the board.
      Answer in one sentence that includes the figure the tool returned.
    TEXT

    TIDE_QUESTION = <<~TEXT.strip
      Wednesday 14 October 2026, morning watch at Point Wilson.
      Tide reference: https://tidesandcurrents.noaa.gov/stationhome.html?id=9444900
      When does the foghorn tender Alden clear the kelp ledge?
    TEXT

    HORN_QUESTION = "The relief asks whether Alden still clears at the time you just posted."

    Result = Struct.new(
      :tide_answer,
      :follow_up,
      :roles,
      :tool_content,
      :tool_call_count,
      :model_class,
      :usage_count,
      :entry_count,
      keyword_init: true
    )

    def self.conduct
      log = open_log
      log.with_instructions(INSTRUCTIONS)
      log.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(log, provider: :openai)
      log.with_tools(PostedTideBoard)
      log.with_tool_options(choice: PostedTideBoard)
      tide = log.ask(TIDE_QUESTION)

      log.with_tool_options(choice: :none)
      follow_up = log.ask(HORN_QUESTION)

      tool_entry = log.desk_entries.find { |entry| entry.role.to_s == "tool" }
      Result.new(
        tide_answer: tide.content,
        follow_up: follow_up.content,
        roles: log.desk_entries.map { |entry| entry.role.to_sym },
        tool_content: tool_entry&.content,
        tool_call_count: RubyLLM::ActiveRecord::ToolCall.count,
        model_class: log.model.class.name,
        usage_count: log.ruby_llm_usages.count,
        entry_count: log.desk_entries.count
      )
    end

    def self.open_log
      choice = boot
      WatchDeskLog.create!(**choice)
    end

    def self.boot
      Multivitamin::ActiveRecordBoot.prepare!(
        chat_table: :admiralty_inlet_watch_desk_logs,
        message_table: :admiralty_inlet_desk_entries,
        message_foreign_key: :admiralty_inlet_watch_desk_log_id
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
  Multivitamin::Cassettes.play(__dir__, "watch_desk") do
    result = AdmiraltyInletPersistedWatchDesk::WatchClerk.conduct
  end

  puts result.tide_answer
  puts
  puts result.follow_up
end
