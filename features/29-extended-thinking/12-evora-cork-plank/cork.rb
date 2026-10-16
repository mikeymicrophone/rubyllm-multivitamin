# frozen_string_literal: true

# Extended thinking · 12 · Évora cork plank
#
# Teaches:
# - acts_as_message stores thinking_text and thinking_signature.
# - Reload the cork log; the thinking columns are still there.
# - tokens.thinking lives on the usage ledger, not those columns.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

require_relative "../../../support/active_record"

module EvoraCorkPlank
  class CorkLog < ActiveRecord::Base
    self.table_name = "evora_cork_logs"
    acts_as_chat messages: :cork_entries,
                 message_class: "EvoraCorkPlank::CorkEntry",
                 messages_foreign_key: :evora_cork_log_id
  end

  class CorkEntry < ActiveRecord::Base
    self.table_name = "evora_cork_entries"
    acts_as_message chat: :cork_log,
                    chat_class: "EvoraCorkPlank::CorkLog",
                    chat_foreign_key: :evora_cork_log_id
  end

  class CorkClerk
    INSTRUCTIONS = <<~TEXT.strip
      You are the cork clerk in Évora.
      Answer in one short sentence from the board only.
      The sentence must include the name Inês and the time 12:30.
      Do not replace Inês with a pronoun.
    TEXT

    BOARD = "Board: Inês grades plank EVO-2026-1016-C2 at 12:30. When does Inês grade?"

    Result = Struct.new(
      :brief,
      :thinking_text,
      :thinking_signature,
      :reloaded_text,
      :reloaded_signature,
      :assistant_count,
      keyword_init: true
    )

    def self.conduct
      log = open_log
      log.with_thinking(effort: :medium, display: :summarized)
      log.with_instructions(INSTRUCTIONS)
      brief = log.ask(BOARD)

      assistant = log.cork_entries.find_by(role: "assistant")
      reloaded = CorkLog.find(log.id)
      reloaded_assistant = reloaded.cork_entries.find_by(role: "assistant")

      Result.new(
        brief: brief.content,
        thinking_text: assistant.thinking_text,
        thinking_signature: assistant.thinking_signature,
        reloaded_text: reloaded_assistant.thinking_text,
        reloaded_signature: reloaded_assistant.thinking_signature,
        assistant_count: log.cork_entries.where(role: "assistant").count
      )
    end

    def self.open_log
      boot
      CorkLog.create!(model: Multivitamin::Models::OPENAI_REASONING, provider: :openai)
    end

    def self.boot
      Multivitamin::ActiveRecordBoot.prepare!(
        chat_table: :evora_cork_logs,
        message_table: :evora_cork_entries,
        message_foreign_key: :evora_cork_log_id
      )
      Multivitamin::ActiveRecordBoot.seed_model(
        model_id: Multivitamin::Models::OPENAI_REASONING,
        provider: :openai
      )
      configure
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
  Multivitamin::Cassettes.play(__dir__, "cork") do
    result = EvoraCorkPlank::CorkClerk.conduct
  end

  puts result.brief
  puts "thinking=#{result.thinking_text.to_s.bytesize}"
end
