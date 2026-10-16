# frozen_string_literal: true

# Rails integration · 03 · Oaxaca alebrije-firing plate
#
# Teaches:
# - ask on a persisted chat accepts with: a local photograph.
# - The user row is saved. The request carries the image.
# - Without Active Storage, the blob is not a message association;
#   the file still goes out on that first ask.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/active_record"

module OaxacaAlebrijePlate
  class FiringLog < ActiveRecord::Base
    self.table_name = "oaxaca_firing_logs"
    acts_as_chat messages: :plate_entries,
                 message_class: "OaxacaAlebrijePlate::PlateEntry",
                 messages_foreign_key: :oaxaca_firing_log_id
  end

  class PlateEntry < ActiveRecord::Base
    self.table_name = "oaxaca_plate_entries"
    acts_as_message chat: :firing_log,
                    chat_class: "OaxacaAlebrijePlate::FiringLog",
                    chat_foreign_key: :oaxaca_firing_log_id
  end

  class FiringPlate
    PHOTO = File.expand_path("kiln-card.png", __dir__)

    INSTRUCTIONS = <<~TEXT.strip
      You are the kiln clerk in a family alebrije workshop in San Martín Tilcajete, Oaxaca.
      Answer in one sentence from the photograph only.
      Include the soak time, the kiln pressure, and the clock when Rufina unloads the jaguar.
    TEXT

    BOARD_QUESTION = <<~TEXT.strip
      The photograph is the kiln card posted in San Martín Tilcajete for Wednesday 14 October 2026.
      Workshop page: https://www.oaxaca.gob.mx/artes-culturas-y-pueblos-indigenas/
      When is the soak, what is that pressure, and when does Rufina unload the jaguar?
    TEXT

    Result = Struct.new(:brief, :roles, :user_content, :finish, :input_tokens, keyword_init: true)

    def self.conduct
      log = open_log
      log.with_instructions(INSTRUCTIONS)
      log.with_temperature(0)
      Multivitamin::Models.quiet_thinking(log, provider: :openai)
      brief = log.ask(BOARD_QUESTION, with: PHOTO)
      user = log.plate_entries.find { |entry| entry.role.to_s == "user" }

      Result.new(
        brief: brief.content,
        roles: log.plate_entries.map { |entry| entry.role.to_sym },
        user_content: user&.content,
        finish: brief.finish_reason,
        input_tokens: brief.tokens.input
      )
    end

    def self.open_log
      choice = boot
      FiringLog.create!(**choice)
    end

    def self.boot
      Multivitamin::ActiveRecordBoot.prepare!(
        chat_table: :oaxaca_firing_logs,
        message_table: :oaxaca_plate_entries,
        message_foreign_key: :oaxaca_firing_log_id
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
  Multivitamin::Cassettes.play(__dir__, "firing_plate") do
    result = OaxacaAlebrijePlate::FiringPlate.conduct
  end

  puts result.brief
end
