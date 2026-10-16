# frozen_string_literal: true

# Batches · 10 · Vigevano shoe-last Rails batch table
#
# Teaches:
# - ruby_llm_batches stores provider_batch_id after RubyLLM.batch.
# - ActiveRecord chats with ask_later persist into that row's chat_ids.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/active_record"

module VigevanoShoeLast
  class LastLog < ActiveRecord::Base
    self.table_name = "vigevano_last_logs"
    acts_as_chat messages: :last_entries,
                 message_class: "VigevanoShoeLast::LastEntry",
                 messages_foreign_key: :vigevano_last_log_id
  end

  class LastEntry < ActiveRecord::Base
    self.table_name = "vigevano_last_entries"
    acts_as_message chat: :last_log,
                    chat_class: "VigevanoShoeLast::LastLog",
                    chat_foreign_key: :vigevano_last_log_id
  end

  class ShoeBatch
    INSTRUCTIONS = <<~TEXT.strip
      You are the last clerk at the shoe loft in Vigevano.
      Answer in one short sentence from the card only.
      Name 15 pairs and Giada.
    TEXT

    CARD = <<~TEXT.strip
      Vigevano shoe-last loft card, Friday 16 October 2026.
      15 pairs on the east last. Giada nails the next heel.
      How many pairs, and who nails the heel?
    TEXT

    Result = Struct.new(:batch_id, :row_id, :chat_ids, :provider, :status, keyword_init: true)

    def self.conduct
      choice = boot
      log = LastLog.create!(**choice)
      log.with_instructions(INSTRUCTIONS)
      log.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(log, provider: :openai)
      log.ask_later(CARD)
      batch = RubyLLM.batch([log])
      row = RubyLLM::ActiveRecord::Batch.find_by!(provider_batch_id: batch.id)
      Result.new(
        batch_id: batch.id,
        row_id: row.id,
        chat_ids: row.chat_ids,
        provider: row.provider,
        status: row.status
      )
    end

    def self.boot
      Multivitamin::ActiveRecordBoot.prepare!(
        chat_table: :vigevano_last_logs,
        message_table: :vigevano_last_entries,
        message_foreign_key: :vigevano_last_log_id
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

    def self.open_chat(model: nil)
      kwargs = Multivitamin::Models.chat(provider: :openai)
      kwargs = kwargs.merge(model: model) if model
      chat = RubyLLM.chat(**kwargs)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "shoe_last") do
    result = VigevanoShoeLast::ShoeBatch.conduct
  end
  puts "id=#{result.batch_id} row=#{result.row_id} chats=#{result.chat_ids.inspect}"
end
