# frozen_string_literal: true

# Rails integration · 06 · Smith Island weather clerk
#
# Teaches:
# - with_instructions persists a system row on the weather log.
# - append: true adds a second system row instead of replacing the first.
# - messages.where(role: :system) reads those rows back after a reload.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/active_record"

module SmithIslandWeatherClerk
  class WeatherLog < ActiveRecord::Base
    self.table_name = "smith_island_weather_logs"
    acts_as_chat messages: :weather_entries,
                 message_class: "SmithIslandWeatherClerk::WeatherEntry",
                 messages_foreign_key: :smith_island_weather_log_id
  end

  class WeatherEntry < ActiveRecord::Base
    self.table_name = "smith_island_weather_entries"
    acts_as_message chat: :weather_log,
                    chat_class: "SmithIslandWeatherClerk::WeatherLog",
                    chat_foreign_key: :smith_island_weather_log_id
  end

  class WeatherClerk
    STATION_RULE = <<~TEXT.strip
      You are the weather clerk at Smith Island Light Station.
      Answer in one short sentence from the glass only.
      Name the barometer 29.84 and the word falling.
    TEXT

    GLASS_RULE = <<~TEXT.strip
      Add the wind: southwesterly 18 knots at the lighthouse.
      Keep the barometer figure.
    TEXT

    GLASS_QUESTION = <<~TEXT.strip
      Barometer glass at Smith Island, Wednesday 14 October 2026 at 14:00.
      Station page: https://tidesandcurrents.noaa.gov/stationhome.html?id=9440910
      The mercury stands at 29.84 in and is falling.
      What does the incoming watch need from the glass?
    TEXT

    Result = Struct.new(
      :brief,
      :system_count,
      :system_texts,
      :reloaded_system_count,
      :roles,
      keyword_init: true
    )

    def self.conduct
      log = open_log
      log.with_instructions(STATION_RULE)
      log.with_instructions(GLASS_RULE, append: true)
      log.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(log, provider: :openai)
      brief = log.ask(GLASS_QUESTION)

      systems = log.weather_entries.where(role: :system)
      reloaded = WeatherLog.find(log.id)
      Result.new(
        brief: brief.content,
        system_count: systems.count,
        system_texts: systems.order(:id).map(&:content),
        reloaded_system_count: reloaded.weather_entries.where(role: :system).count,
        roles: log.weather_entries.map { |entry| entry.role.to_sym }
      )
    end

    def self.open_log
      choice = boot
      WeatherLog.create!(**choice)
    end

    def self.boot
      Multivitamin::ActiveRecordBoot.prepare!(
        chat_table: :smith_island_weather_logs,
        message_table: :smith_island_weather_entries,
        message_foreign_key: :smith_island_weather_log_id
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
  Multivitamin::Cassettes.play(__dir__, "weather_clerk") do
    result = SmithIslandWeatherClerk::WeatherClerk.conduct
  end

  puts result.brief
end
