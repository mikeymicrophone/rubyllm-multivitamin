# frozen_string_literal: true

# Rails integration · 01 · Ibadan school-farm log
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

module IbadanSchoolFarmLog
  class FarmLog < ActiveRecord::Base
    self.table_name = "ibadan_farm_logs"
    acts_as_chat messages: :plot_entries,
                 message_class: "IbadanSchoolFarmLog::PlotEntry",
                 messages_foreign_key: :ibadan_farm_log_id
  end

  class PlotEntry < ActiveRecord::Base
    self.table_name = "ibadan_plot_entries"
    acts_as_message chat: :farm_log,
                    chat_class: "IbadanSchoolFarmLog::FarmLog",
                    chat_foreign_key: :ibadan_farm_log_id
  end

  class FarmClerk
    INSTRUCTIONS = <<~TEXT.strip
      You are the school-farm clerk at Government College Ibadan.
      Answer in one short sentence from the board only.
      Name Amina and the clock 07:15.
    TEXT

    BOARD_QUESTION = <<~TEXT.strip
      Harvest board posted for Wednesday 14 October 2026 at Government College Ibadan.
      College page: https://gci.sch.ng/
      Cassava plot C3 is ready at 07:15. Amina leads the Form Four cut.
      Yam mounds stay closed until the afternoon bell.
      When does Amina start the cassava cut?
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
        entry_count: log.plot_entries.count,
        roles: log.plot_entries.map { |entry| entry.role.to_sym },
        model_id: log.model_id,
        provider: log.provider,
        model_class: log.model.class.name,
        persisted: log.persisted?
      )
    end

    def self.open_log
      choice = boot
      FarmLog.create!(**choice)
    end

    def self.boot
      Multivitamin::ActiveRecordBoot.prepare!(
        chat_table: :ibadan_farm_logs,
        message_table: :ibadan_plot_entries,
        message_foreign_key: :ibadan_farm_log_id
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
  Multivitamin::Cassettes.play(__dir__, "farm_log") do
    result = IbadanSchoolFarmLog::FarmClerk.conduct
  end

  puts result.brief
  puts
  puts "#{result.entry_count} entries on #{result.model_id}"
end
