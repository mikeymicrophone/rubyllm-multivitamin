# frozen_string_literal: true

# Rails integration · 11 · Port Angeles net transcripts
#
# Teaches:
# - acts_as_chat messages: :llm_messages points RubyLLM at a different
#   association than the loft tickets the clerk posts.
# - The model sees only llm_messages. The loft log can hold a shorter note.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/active_record"

module PortAngelesNetTranscripts
  class NetLog < ActiveRecord::Base
    self.table_name = "port_angeles_net_logs"
    has_many :loft_tickets,
             class_name: "PortAngelesNetTranscripts::LoftTicket",
             foreign_key: :port_angeles_net_log_id,
             dependent: :destroy
    acts_as_chat messages: :llm_messages,
                 message_class: "PortAngelesNetTranscripts::LlmMessage",
                 messages_foreign_key: :port_angeles_net_log_id
  end

  class LlmMessage < ActiveRecord::Base
    self.table_name = "port_angeles_llm_messages"
    acts_as_message chat: :net_log,
                    chat_class: "PortAngelesNetTranscripts::NetLog",
                    chat_foreign_key: :port_angeles_net_log_id
  end

  class LoftTicket < ActiveRecord::Base
    self.table_name = "port_angeles_loft_tickets"
    belongs_to :net_log, class_name: "PortAngelesNetTranscripts::NetLog",
                         foreign_key: :port_angeles_net_log_id
  end

  class NetLoftClerk
    INSTRUCTIONS = <<~TEXT.strip
      You are the net loft clerk at Port Angeles.
      Answer in one short sentence from the mending ticket only.
      Name corkline 4 and the 18 fathoms of #21 twine.
    TEXT

    MENDING_QUESTION = <<~TEXT.strip
      Mending ticket at the Port Angeles net loft, Wednesday 14 October 2026.
      Loft page: https://www.portofpa.com/
      Corkline 4 needs 18 fathoms of #21 twine. The purse rings stay on.
      What does the loft hang for the seiner Kulshan?
    TEXT

    Result = Struct.new(
      :brief,
      :llm_roles,
      :llm_count,
      :loft_count,
      :loft_note,
      keyword_init: true
    )

    def self.conduct
      log = open_log
      log.with_instructions(INSTRUCTIONS)
      log.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(log, provider: :openai)
      brief = log.ask(MENDING_QUESTION)
      log.loft_tickets.create!(role: "clerk", content: brief.content)

      Result.new(
        brief: brief.content,
        llm_roles: log.llm_messages.map { |entry| entry.role.to_sym },
        llm_count: log.llm_messages.count,
        loft_count: log.loft_tickets.count,
        loft_note: log.loft_tickets.first.content
      )
    end

    def self.open_log
      choice = boot
      NetLog.create!(**choice)
    end

    def self.boot
      Multivitamin::ActiveRecordBoot.prepare!(
        chat_table: :port_angeles_net_logs,
        message_table: :port_angeles_llm_messages,
        message_foreign_key: :port_angeles_net_log_id
      )
      ActiveRecord::Schema.define do
        create_table :port_angeles_loft_tickets do |t|
          t.integer :port_angeles_net_log_id, null: false
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
  Multivitamin::Cassettes.play(__dir__, "net_transcripts") do
    result = PortAngelesNetTranscripts::NetLoftClerk.conduct
  end

  puts result.brief
end
