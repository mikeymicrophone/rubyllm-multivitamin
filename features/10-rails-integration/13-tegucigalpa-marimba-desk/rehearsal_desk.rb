# frozen_string_literal: true

# Rails integration · 13 · Tegucigalpa marimba desk
#
# Teaches:
# - A persisted rehearsal desk keeps the chat, the messages, a tool call,
#   the model association, and a usage row on one log.
# - A second ask on the same record sends the earlier tool result back.
# - RubyLLM::ActiveRecord::Model and ToolCall stay the gem's records.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/active_record"

module TegucigalpaPersistedMarimbaDesk
  class RehearsalLog < ActiveRecord::Base
    self.table_name = "tegucigalpa_rehearsal_logs"
    acts_as_chat messages: :desk_entries,
                 message_class: "TegucigalpaPersistedMarimbaDesk::DeskEntry",
                 messages_foreign_key: :tegucigalpa_rehearsal_log_id
  end

  class DeskEntry < ActiveRecord::Base
    self.table_name = "tegucigalpa_desk_entries"
    acts_as_message chat: :rehearsal_log,
                    chat_class: "TegucigalpaPersistedMarimbaDesk::RehearsalLog",
                    chat_foreign_key: :tegucigalpa_rehearsal_log_id
  end

  class PostedRehearsalBoard < RubyLLM::Tool
    description "Reads the conservatory marimba board, including when the downbeat falls"

    def self.tool_name
      "posted_rehearsal_board"
    end

    def execute
      "Marimba board. Mallet 7 is on the tenor bar. Downbeat 10:12."
    end
  end

  class DeskClerk
    INSTRUCTIONS = <<~TEXT.strip
      You are the rehearsal clerk at the Escuela Nacional de Música in Tegucigalpa.
      Call posted_rehearsal_board when the question needs the board.
      Answer in one sentence that includes the figure the tool returned.
    TEXT

    BOARD_QUESTION = <<~TEXT.strip
      Wednesday 14 October 2026, morning rehearsal in Tegucigalpa.
      Conservatory page: https://www.se.gob.hn/
      When does the marimba downbeat fall?
    TEXT

    FOLLOW_QUESTION = "The relief asks whether the downbeat still falls at the time you just posted."

    Result = Struct.new(
      :board_answer,
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
      log.with_tools(PostedRehearsalBoard)
      log.with_tool_options(choice: PostedRehearsalBoard)
      board = log.ask(BOARD_QUESTION)

      log.with_tool_options(choice: :none)
      follow_up = log.ask(FOLLOW_QUESTION)

      tool_entry = log.desk_entries.find { |entry| entry.role.to_s == "tool" }
      Result.new(
        board_answer: board.content,
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
      RehearsalLog.create!(**choice)
    end

    def self.boot
      Multivitamin::ActiveRecordBoot.prepare!(
        chat_table: :tegucigalpa_rehearsal_logs,
        message_table: :tegucigalpa_desk_entries,
        message_foreign_key: :tegucigalpa_rehearsal_log_id
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
  Multivitamin::Cassettes.play(__dir__, "rehearsal_desk") do
    result = TegucigalpaPersistedMarimbaDesk::DeskClerk.conduct
  end

  puts result.board_answer
  puts
  puts result.follow_up
end
