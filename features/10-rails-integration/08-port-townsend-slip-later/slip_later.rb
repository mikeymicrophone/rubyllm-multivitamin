# frozen_string_literal: true

# Rails integration · 08 · Port Townsend slip later
#
# Teaches:
# - ask_later persists the slip clerk's question without a provider call.
# - complete runs the request later, the way a job would, and fills the
#   assistant row.
# - The user count does not change when complete runs.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/active_record"

module PortTownsendSlipLater
  class SlipLog < ActiveRecord::Base
    self.table_name = "port_townsend_slip_logs"
    acts_as_chat messages: :slip_entries,
                 message_class: "PortTownsendSlipLater::SlipEntry",
                 messages_foreign_key: :port_townsend_slip_log_id
  end

  class SlipEntry < ActiveRecord::Base
    self.table_name = "port_townsend_slip_entries"
    acts_as_message chat: :slip_log,
                    chat_class: "PortTownsendSlipLater::SlipLog",
                    chat_foreign_key: :port_townsend_slip_log_id
  end

  class SlipClerk
    INSTRUCTIONS = <<~TEXT.strip
      You are the slip clerk at the Port Townsend ferry slip.
      Answer in one short sentence from the wind board only.
      Name the 28-knot gust and the Kalakala holding.
    TEXT

    WIND_QUESTION = <<~TEXT.strip
      Wind board at the Port Townsend ferry slip, Wednesday 14 October 2026.
      Terminal page: https://wsdot.wa.gov/travel/washington-state-ferries
      Southwesterly 18 knots, gusting 28. The Kalakala holds for the gust.
      What does the incoming watch post?
    TEXT

    Result = Struct.new(
      :brief,
      :count_after_later,
      :count_after_complete,
      :user_count_after_later,
      :assistant_after_later,
      :roles,
      keyword_init: true
    )

    def self.conduct
      log = open_log
      log.with_instructions(INSTRUCTIONS)
      log.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(log, provider: :openai)
      log.ask_later(WIND_QUESTION)

      count_after_later = log.slip_entries.count
      user_count_after_later = log.slip_entries.where(role: :user).count
      assistant_after_later = log.slip_entries.where(role: :assistant).count

      brief = log.complete
      Result.new(
        brief: brief.content,
        count_after_later: count_after_later,
        count_after_complete: log.slip_entries.count,
        user_count_after_later: user_count_after_later,
        assistant_after_later: assistant_after_later,
        roles: log.slip_entries.map { |entry| entry.role.to_sym }
      )
    end

    def self.open_log
      choice = boot
      SlipLog.create!(**choice)
    end

    def self.boot
      Multivitamin::ActiveRecordBoot.prepare!(
        chat_table: :port_townsend_slip_logs,
        message_table: :port_townsend_slip_entries,
        message_foreign_key: :port_townsend_slip_log_id
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
  Multivitamin::Cassettes.play(__dir__, "slip_later") do
    result = PortTownsendSlipLater::SlipClerk.conduct
  end

  puts result.brief
end
