# frozen_string_literal: true

# Rails integration · 04 · Kumasi fontomfrom stream
#
# Teaches:
# - A streamed ask on a persisted drum log creates the assistant row
#   before the first chunk, with empty content.
# - Chunks fill that same row. The saved content matches the joined speech.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/active_record"

module KumasiFontomfromStream
  class DrumLog < ActiveRecord::Base
    self.table_name = "kumasi_drum_logs"
    acts_as_chat messages: :drum_entries,
                 message_class: "KumasiFontomfromStream::DrumEntry",
                 messages_foreign_key: :kumasi_drum_log_id
  end

  class DrumEntry < ActiveRecord::Base
    self.table_name = "kumasi_drum_entries"
    acts_as_message chat: :drum_log,
                    chat_class: "KumasiFontomfromStream::DrumLog",
                    chat_foreign_key: :kumasi_drum_log_id
  end

  class DrumStream
    INSTRUCTIONS = <<~TEXT.strip
      You are the fontomfrom clerk at the Centre for National Culture in Kumasi.
      Dictate the card in two short sentences.
      Name the three-stroke call and the 27-count silence.
    TEXT

    CARD_QUESTION = <<~TEXT.strip
      Fontomfrom card posted Wednesday 14 October 2026 at the Centre for National Culture, Kumasi.
      Centre page: https://www.ghana.gov.gh/
      Call 3 strokes, silent 27 counts. The atumpan is tight.
      Dictate that pattern for the incoming ensemble.
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
        assistant = log.drum_entries.where(role: "assistant").order(:id).last
        blank_before_chunks = assistant&.content if assistant && blank_before_chunks.nil?
      end

      pieces = []
      message = log.ask(CARD_QUESTION) do |chunk|
        piece = chunk.content.to_s
        pieces << piece unless piece.empty?
      end

      assistant = log.drum_entries.find { |entry| entry.role.to_s == "assistant" }
      Result.new(
        speech: message.content,
        saved_content: assistant&.content,
        blank_before_chunks: blank_before_chunks,
        chunk_count: pieces.size,
        roles: log.drum_entries.map { |entry| entry.role.to_sym }
      )
    end

    def self.open_log
      choice = boot
      DrumLog.create!(**choice)
    end

    def self.boot
      Multivitamin::ActiveRecordBoot.prepare!(
        chat_table: :kumasi_drum_logs,
        message_table: :kumasi_drum_entries,
        message_foreign_key: :kumasi_drum_log_id
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
  Multivitamin::Cassettes.play(__dir__, "drum_stream") do
    result = KumasiFontomfromStream::DrumStream.conduct
  end

  puts result.speech
end
