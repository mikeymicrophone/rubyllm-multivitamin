# frozen_string_literal: true

# Rails integration · 12 · Antofagasta flash-furnace cancel
#
# Teaches:
# - cancel on a persisted furnace log sets the cancelled column and raises
#   RubyLLM::CancelledError at the next chunk.
# - The blank assistant row created for the stream is destroyed.
# - CancelledError inherits StandardError, not RubyLLM::Error.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/active_record"

module AntofagastaFurnaceCancel
  class FurnaceLog < ActiveRecord::Base
    self.table_name = "antofagasta_furnace_logs"
    acts_as_chat messages: :furnace_entries,
                 message_class: "AntofagastaFurnaceCancel::FurnaceEntry",
                 messages_foreign_key: :antofagasta_furnace_log_id
  end

  class FurnaceEntry < ActiveRecord::Base
    self.table_name = "antofagasta_furnace_entries"
    acts_as_message chat: :furnace_log,
                    chat_class: "AntofagastaFurnaceCancel::FurnaceLog",
                    chat_foreign_key: :antofagasta_furnace_log_id
  end

  class FurnaceClerk
    INSTRUCTIONS = <<~TEXT.strip
      You are the furnace clerk at a copper smelter outside Antofagasta.
      Call four corrections in order, one short sentence each.
      Use only the notice on the card.
    TEXT

    NOTICE_QUESTION = <<~TEXT.strip
      Furnace notice Wednesday 14 October 2026, Antofagasta smelter.
      Codelco page: https://www.codelco.com/
      First correction: tap-hole 3 is frozen.
      Second correction: the waste-heat boiler is tripped.
      Third correction: converter 2 is as posted.
      Fourth correction: concentrate bin 5 is silent.
      Call the four corrections.
    TEXT

    Result = Struct.new(
      :spoken,
      :error_class,
      :error_parent,
      :cancelled_during,
      :roles,
      :assistant_count,
      keyword_init: true
    )

    def self.conduct
      log = open_log
      log.with_instructions(INSTRUCTIONS)
      log.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(log, provider: :openai)

      spoken = []
      cancelled_during = false
      error = nil
      begin
        log.ask(NOTICE_QUESTION) do |chunk|
          piece = chunk.content.to_s
          next if piece.empty?

          spoken << piece
          if spoken.size == 2
            log.cancel
            cancelled_during = log.cancelled?
          end
        end
      rescue RubyLLM::CancelledError => raised
        error = raised
      end

      Result.new(
        spoken: spoken,
        error_class: error&.class,
        error_parent: error&.class&.superclass,
        cancelled_during: cancelled_during,
        roles: log.furnace_entries.map { |entry| entry.role.to_sym },
        assistant_count: log.furnace_entries.where(role: :assistant).count
      )
    end

    def self.open_log
      choice = boot
      FurnaceLog.create!(**choice)
    end

    def self.boot
      Multivitamin::ActiveRecordBoot.prepare!(
        chat_table: :antofagasta_furnace_logs,
        message_table: :antofagasta_furnace_entries,
        message_foreign_key: :antofagasta_furnace_log_id
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
  Multivitamin::Cassettes.play(__dir__, "furnace_cancel") do
    result = AntofagastaFurnaceCancel::FurnaceClerk.conduct
  end

  puts result.spoken.join
  puts
  puts result.error_class
end
