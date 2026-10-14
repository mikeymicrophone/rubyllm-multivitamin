# frozen_string_literal: true

# Rails integration · 04 · Cape Disappointment blast stream
#
# Teaches:
# - A streamed ask on a persisted horn log creates the assistant row
#   before the first chunk, with empty content.
# - Chunks fill that same row. The saved content matches the joined speech.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/active_record"

module CapeDisappointmentBlastStream
  class HornLog < ActiveRecord::Base
    self.table_name = "cape_disappointment_horn_logs"
    acts_as_chat messages: :horn_entries,
                 message_class: "CapeDisappointmentBlastStream::HornEntry",
                 messages_foreign_key: :cape_disappointment_horn_log_id
  end

  class HornEntry < ActiveRecord::Base
    self.table_name = "cape_disappointment_horn_entries"
    acts_as_message chat: :horn_log,
                    chat_class: "CapeDisappointmentBlastStream::HornLog",
                    chat_foreign_key: :cape_disappointment_horn_log_id
  end

  class BlastStream
    INSTRUCTIONS = <<~TEXT.strip
      You are the horn keeper at Cape Disappointment Light Station.
      Dictate the card in two short sentences.
      Name the three-second blast and the 27-second silence.
    TEXT

    CARD_QUESTION = <<~TEXT.strip
      Foghorn card posted Wednesday 14 October 2026 at Cape Disappointment.
      Station page: https://www.nps.gov/lewi/planyourvisit/cape-disappointment.htm
      Blast 3 seconds, silent 27 seconds. The compressor is on.
      Dictate that pattern for the incoming watch.
    TEXT

    Result = Struct.new(
      :speech,
      :saved_content,
      :blank_before_chunks,
      :chunk_count,
      :roles,
      keyword_init: true
    )

    def self.conduct
      log = open_log
      log.with_instructions(INSTRUCTIONS)
      log.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(log, provider: :openai)

      blank_before_chunks = nil
      log.to_llm.before_message do
        assistant = log.horn_entries.where(role: "assistant").order(:id).last
        blank_before_chunks = assistant&.content if assistant && blank_before_chunks.nil?
      end

      pieces = []
      message = log.ask(CARD_QUESTION) do |chunk|
        piece = chunk.content.to_s
        pieces << piece unless piece.empty?
      end

      assistant = log.horn_entries.find { |entry| entry.role.to_s == "assistant" }
      Result.new(
        speech: message.content,
        saved_content: assistant&.content,
        blank_before_chunks: blank_before_chunks,
        chunk_count: pieces.size,
        roles: log.horn_entries.map { |entry| entry.role.to_sym }
      )
    end

    def self.open_log
      choice = boot
      HornLog.create!(**choice)
    end

    def self.boot
      Multivitamin::ActiveRecordBoot.prepare!(
        chat_table: :cape_disappointment_horn_logs,
        message_table: :cape_disappointment_horn_entries,
        message_foreign_key: :cape_disappointment_horn_log_id
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
  Multivitamin::Cassettes.play(__dir__, "blast_stream") do
    result = CapeDisappointmentBlastStream::BlastStream.conduct
  end

  puts result.speech
end
