# frozen_string_literal: true

# Prompt caching · 08 · Cotonou zémidjan fare
#
# Teaches:
# - acts_as_message stores cache_until_here and cache_ttl on the system row.
# - with_caching(false) keeps the breakpoint off the wire, so gpt-4.1-mini
#   still answers. Reload the fare log; the boundary is still there.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/active_record"

module CotonouZemidjanFare
  class FareLog < ActiveRecord::Base
    self.table_name = "cotonou_fare_logs"
    acts_as_chat messages: :fare_entries,
                 message_class: "CotonouZemidjanFare::FareEntry",
                 messages_foreign_key: :cotonou_fare_log_id
  end

  class FareEntry < ActiveRecord::Base
    self.table_name = "cotonou_fare_entries"
    acts_as_message chat: :fare_log,
                    chat_class: "CotonouZemidjanFare::FareLog",
                    chat_foreign_key: :cotonou_fare_log_id
  end

  class FareClerk
    POLICY = (1..16).map { |n|
      "Cotonou zémidjan standing order #{n}: bike #{n} is run COT-2026-1016-Z#{n}."
    }.join(" ")

    INSTRUCTIONS = <<~TEXT.strip
      You are the zémidjan clerk in Cotonou.
      #{POLICY}
      Answer in one short sentence from the board only.
      Name Koffi and 06:40.
    TEXT

    BOARD = "Board: Koffi starts run COT-2026-1016-Z3 at 06:40. When does Koffi start?"

    Result = Struct.new(
      :brief,
      :cache_until_here,
      :cache_ttl,
      :reloaded_ttl,
      :system_count,
      keyword_init: true
    )

    def self.conduct
      log = open_log
      log.with_instructions(INSTRUCTIONS, cache_until_here: { ttl: "1h" })
      log.with_caching(false)
      log.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(log, provider: :openai)
      brief = log.ask(BOARD)

      system_row = log.fare_entries.find_by(role: "system")
      reloaded = FareLog.find(log.id)
      reloaded_system = reloaded.fare_entries.find_by(role: "system")

      Result.new(
        brief: brief.content,
        cache_until_here: system_row.cache_until_here?,
        cache_ttl: system_row.cache_ttl,
        reloaded_ttl: reloaded_system.cache_ttl,
        system_count: log.fare_entries.where(role: "system").count
      )
    end

    def self.open_log
      choice = boot
      FareLog.create!(**choice)
    end

    def self.boot
      Multivitamin::ActiveRecordBoot.prepare!(
        chat_table: :cotonou_fare_logs,
        message_table: :cotonou_fare_entries,
        message_foreign_key: :cotonou_fare_log_id
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
  Multivitamin::Cassettes.play(__dir__, "zemidjan_fare") do
    result = CotonouZemidjanFare::FareClerk.conduct
  end

  puts result.brief
  puts "ttl=#{result.cache_ttl} boundary=#{result.cache_until_here}"
end
