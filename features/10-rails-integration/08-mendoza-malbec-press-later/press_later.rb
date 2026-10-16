# frozen_string_literal: true

# Rails integration · 08 · Mendoza malbec-press later
#
# Teaches:
# - ask_later persists the cellar clerk's question without a provider call.
# - complete runs the request later, the way a job would, and fills the
#   assistant row.
# - The user count does not change when complete runs.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/active_record"

module MendozaMalbecPressLater
  class PressLog < ActiveRecord::Base
    self.table_name = "mendoza_press_logs"
    acts_as_chat messages: :press_entries,
                 message_class: "MendozaMalbecPressLater::PressEntry",
                 messages_foreign_key: :mendoza_press_log_id
  end

  class PressEntry < ActiveRecord::Base
    self.table_name = "mendoza_press_entries"
    acts_as_message chat: :press_log,
                    chat_class: "MendozaMalbecPressLater::PressLog",
                    chat_foreign_key: :mendoza_press_log_id
  end

  class PressClerk
    INSTRUCTIONS = <<~TEXT.strip
      You are the cellar clerk at Finca Luján in Luján de Cuyo, Mendoza.
      Answer in one short sentence from the must board only.
      Name the 28-degree must and press 3 holding.
    TEXT

    MUST_QUESTION = <<~TEXT.strip
      Must board at Finca Luján, Wednesday 14 October 2026.
      Bodega page: https://www.mendoza.gov.ar/
      Malbec must 22 C, peaking 28. Press 3 holds for the peak.
      What does the incoming crush post?
    TEXT

    Result = Struct.new(
      :brief,
      :count_after_later,
      :count_after_complete,
      :user_count_after_later,
      :assistant_after_later,
      :roles,
      keyword_init: true
    )

    def self.conduct
      log = open_log
      log.with_instructions(INSTRUCTIONS)
      log.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(log, provider: :openai)
      log.ask_later(MUST_QUESTION)

      count_after_later = log.press_entries.count
      user_count_after_later = log.press_entries.where(role: :user).count
      assistant_after_later = log.press_entries.where(role: :assistant).count

      brief = log.complete
      Result.new(
        brief: brief.content,
        count_after_later: count_after_later,
        count_after_complete: log.press_entries.count,
        user_count_after_later: user_count_after_later,
        assistant_after_later: assistant_after_later,
        roles: log.press_entries.map { |entry| entry.role.to_sym }
      )
    end

    def self.open_log
      choice = boot
      PressLog.create!(**choice)
    end

    def self.boot
      Multivitamin::ActiveRecordBoot.prepare!(
        chat_table: :mendoza_press_logs,
        message_table: :mendoza_press_entries,
        message_foreign_key: :mendoza_press_log_id
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
  Multivitamin::Cassettes.play(__dir__, "press_later") do
    result = MendozaMalbecPressLater::PressClerk.conduct
  end

  puts result.brief
end
