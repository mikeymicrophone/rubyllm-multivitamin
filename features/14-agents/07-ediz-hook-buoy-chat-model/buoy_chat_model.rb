# frozen_string_literal: true

# Agents · 07 · Ediz Hook buoy chat model
#
# Teaches:
# - chat_model turns on Rails mode. create! returns the ActiveRecord chat.
# - The record has ask. The buoy entries persist with the brief.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/active_record"

module EdizHookBuoyChatModel
  class BuoyLog < ActiveRecord::Base
    self.table_name = "ediz_hook_agent_logs"
    acts_as_chat messages: :buoy_entries,
                 message_class: "EdizHookBuoyChatModel::BuoyEntry",
                 messages_foreign_key: :ediz_hook_agent_log_id
  end

  class BuoyEntry < ActiveRecord::Base
    self.table_name = "ediz_hook_agent_entries"
    acts_as_message chat: :buoy_log,
                    chat_class: "EdizHookBuoyChatModel::BuoyLog",
                    chat_foreign_key: :ediz_hook_agent_log_id
  end

  class BuoyClerk < RubyLLM::Agent
    chat_model BuoyLog
    model Multivitamin::Models::OPENAI_CHAT, provider: :openai
    temperature 0.2

    instructions <<~TEXT.strip
      You are the buoy clerk at Ediz Hook.
      Answer in one short sentence from the battery card only.
      Name bell buoy 2 and 12.6 volts.
    TEXT
  end

  class BatteryCard
    CARD_QUESTION = <<~TEXT.strip
      Ediz Hook bell buoy 2 battery card, Wednesday 15 October 2026.
      Station notes: https://www.charts.noaa.gov/
      Posted voltage 12.6. The incoming watch wants the voltage on the log.
      What voltage does the clerk post?
    TEXT

    Result = Struct.new(
      :brief,
      :entry_count,
      :roles,
      :model_id,
      :provider,
      :persisted,
      :record_class,
      keyword_init: true
    )

    def self.conduct
      log = open_log
      Multivitamin::Models.quiet_thinking(log, provider: :openai)
      brief = log.ask(CARD_QUESTION)

      Result.new(
        brief: brief.content,
        entry_count: log.buoy_entries.count,
        roles: log.buoy_entries.map { |entry| entry.role.to_sym },
        model_id: log.model_id,
        provider: log.provider,
        persisted: log.persisted?,
        record_class: log.class.name
      )
    end

    def self.open_log
      chosen = boot
      kwargs = { provider: chosen[:provider] }
      kwargs[:assume_model_exists] = true if chosen[:assume_model_exists]
      BuoyClerk.create!(model: chosen[:model], **kwargs)
    end

    def self.boot
      Multivitamin::ActiveRecordBoot.prepare!(
        chat_table: :ediz_hook_agent_logs,
        message_table: :ediz_hook_agent_entries,
        message_foreign_key: :ediz_hook_agent_log_id
      )
      chosen = Multivitamin::Models.chat(provider: :openai)
      Multivitamin::ActiveRecordBoot.seed_model(model_id: chosen[:model], provider: chosen[:provider])
      configure
      chosen
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
  Multivitamin::Cassettes.play(__dir__, "buoy_chat_model") do
    result = EdizHookBuoyChatModel::BatteryCard.conduct
  end

  puts result.brief
  puts
  puts "#{result.entry_count} entries on #{result.model_id}"
end
