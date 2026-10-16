# frozen_string_literal: true

# Rails integration · 07 · Dar es Salaam farebox usage
#
# Teaches:
# - ask on a persisted farebox log writes a ruby_llm_usages row.
# - The row's token columns match response.tokens.
# - chat.ruby_llm_usages is the association; chat.tokens still aggregates.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/active_record"

module DarEsSalaamFareboxUsage
  class FareboxLog < ActiveRecord::Base
    self.table_name = "dar_farebox_logs"
    acts_as_chat messages: :farebox_entries,
                 message_class: "DarEsSalaamFareboxUsage::FareboxEntry",
                 messages_foreign_key: :dar_farebox_log_id
  end

  class FareboxEntry < ActiveRecord::Base
    self.table_name = "dar_farebox_entries"
    acts_as_message chat: :farebox_log,
                    chat_class: "DarEsSalaamFareboxUsage::FareboxLog",
                    chat_foreign_key: :dar_farebox_log_id
  end

  class FareboxTender
    INSTRUCTIONS = <<~TEXT.strip
      You are the farebox clerk at the Ubungo terminal in Dar es Salaam.
      Answer in one short sentence from the service card only.
      Name dala-dala farebox 2 and the 12-volt battery.
    TEXT

    SERVICE_QUESTION = <<~TEXT.strip
      Service card for Ubungo dala-dala farebox 2, Wednesday 14 October 2026.
      DART page: https://www.dart.go.tz/
      The 12-volt battery reads 12.4 V. The validator latch is free.
      What should the incoming tender take from the card?
    TEXT

    Result = Struct.new(
      :brief,
      :usage_count,
      :usage_input,
      :usage_output,
      :usage_status,
      :message_input,
      :chat_input,
      :roles,
      keyword_init: true
    )

    def self.conduct
      log = open_log
      log.with_instructions(INSTRUCTIONS)
      log.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(log, provider: :openai)
      brief = log.ask(SERVICE_QUESTION)

      usage = log.ruby_llm_usages.first
      Result.new(
        brief: brief.content,
        usage_count: log.ruby_llm_usages.count,
        usage_input: usage&.input_tokens,
        usage_output: usage&.output_tokens,
        usage_status: usage&.status,
        message_input: brief.tokens.input,
        chat_input: log.tokens.input,
        roles: log.farebox_entries.map { |entry| entry.role.to_sym }
      )
    end

    def self.open_log
      choice = boot
      FareboxLog.create!(**choice)
    end

    def self.boot
      Multivitamin::ActiveRecordBoot.prepare!(
        chat_table: :dar_farebox_logs,
        message_table: :dar_farebox_entries,
        message_foreign_key: :dar_farebox_log_id
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
  Multivitamin::Cassettes.play(__dir__, "farebox_usage") do
    result = DarEsSalaamFareboxUsage::FareboxTender.conduct
  end

  puts result.brief
end
