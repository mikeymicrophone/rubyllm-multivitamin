# frozen_string_literal: true

# Rails integration · 11 · Lucknow chikan tickets
#
# Teaches:
# - acts_as_chat messages: :llm_messages points RubyLLM at a different
#   association than the stitch tickets the karigar posts.
# - The model sees only llm_messages. The atelier log can hold a shorter note.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/active_record"

module LucknowChikanTickets
  class AtelierLog < ActiveRecord::Base
    self.table_name = "lucknow_atelier_logs"
    has_many :stitch_tickets,
             class_name: "LucknowChikanTickets::StitchTicket",
             foreign_key: :lucknow_atelier_log_id,
             dependent: :destroy
    acts_as_chat messages: :llm_messages,
                 message_class: "LucknowChikanTickets::LlmMessage",
                 messages_foreign_key: :lucknow_atelier_log_id
  end

  class LlmMessage < ActiveRecord::Base
    self.table_name = "lucknow_llm_messages"
    acts_as_message chat: :atelier_log,
                    chat_class: "LucknowChikanTickets::AtelierLog",
                    chat_foreign_key: :lucknow_atelier_log_id
  end

  class StitchTicket < ActiveRecord::Base
    self.table_name = "lucknow_stitch_tickets"
    belongs_to :atelier_log, class_name: "LucknowChikanTickets::AtelierLog",
                             foreign_key: :lucknow_atelier_log_id
  end

  class AtelierClerk
    INSTRUCTIONS = <<~TEXT.strip
      You are the chikankari clerk in a Chowk atelier in Lucknow.
      Answer in one short sentence from the stitch ticket only.
      Name bakhiya 4 and the 18 metres of #21 white thread.
    TEXT

    STITCH_QUESTION = <<~TEXT.strip
      Stitch ticket at the Chowk atelier, Wednesday 14 October 2026.
      Culture page: https://upculture.up.gov.in/
      Bakhiya 4 needs 18 metres of #21 white thread. The shadow work stays on.
      What does the atelier hang for the kurta?
    TEXT

    Result = Struct.new(
      :brief,
      :llm_roles,
      :llm_count,
      :ticket_count,
      :ticket_note,
      keyword_init: true
    )

    def self.conduct
      log = open_log
      log.with_instructions(INSTRUCTIONS)
      log.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(log, provider: :openai)
      brief = log.ask(STITCH_QUESTION)
      log.stitch_tickets.create!(role: "clerk", content: brief.content)

      Result.new(
        brief: brief.content,
        llm_roles: log.llm_messages.map { |entry| entry.role.to_sym },
        llm_count: log.llm_messages.count,
        ticket_count: log.stitch_tickets.count,
        ticket_note: log.stitch_tickets.first.content
      )
    end

    def self.open_log
      choice = boot
      AtelierLog.create!(**choice)
    end

    def self.boot
      Multivitamin::ActiveRecordBoot.prepare!(
        chat_table: :lucknow_atelier_logs,
        message_table: :lucknow_llm_messages,
        message_foreign_key: :lucknow_atelier_log_id
      )
      ActiveRecord::Schema.define do
        create_table :lucknow_stitch_tickets do |t|
          t.integer :lucknow_atelier_log_id, null: false
          t.string :role, null: false
          t.text :content
          t.timestamps
        end
      end
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
  Multivitamin::Cassettes.play(__dir__, "stitch_tickets") do
    result = LucknowChikanTickets::AtelierClerk.conduct
  end

  puts result.brief
end
