# frozen_string_literal: true

# Rails integration · 03 · Point Wilson tide plate
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

module PointWilsonTidePlate
  class TidePlateLog < ActiveRecord::Base
    self.table_name = "point_wilson_tide_plate_logs"
    acts_as_chat messages: :plate_entries,
                 message_class: "PointWilsonTidePlate::PlateEntry",
                 messages_foreign_key: :point_wilson_tide_plate_log_id
  end

  class PlateEntry < ActiveRecord::Base
    self.table_name = "point_wilson_plate_entries"
    acts_as_message chat: :tide_plate_log,
                    chat_class: "PointWilsonTidePlate::TidePlateLog",
                    chat_foreign_key: :point_wilson_tide_plate_log_id
  end

  class TidePlate
    PHOTO = File.expand_path("tide-board.png", __dir__)

    INSTRUCTIONS = <<~TEXT.strip
      You are the tide clerk at Point Wilson Light Station on Admiralty Inlet.
      Answer in one sentence from the photograph only.
      Include the low water time, the low water height, and the clock when Alden clears the kelp ledge.
    TEXT

    BOARD_QUESTION = <<~TEXT.strip
      The photograph is the tide board posted at Point Wilson for Wednesday 14 October 2026.
      Tide reference: https://tidesandcurrents.noaa.gov/stationhome.html?id=9444900
      When is low water, what is that height, and when does Alden clear the kelp ledge?
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
      TidePlateLog.create!(**choice)
    end

    def self.boot
      Multivitamin::ActiveRecordBoot.prepare!(
        chat_table: :point_wilson_tide_plate_logs,
        message_table: :point_wilson_plate_entries,
        message_foreign_key: :point_wilson_tide_plate_log_id
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
  Multivitamin::Cassettes.play(__dir__, "tide_plate") do
    result = PointWilsonTidePlate::TidePlate.conduct
  end

  puts result.brief
end
