# frozen_string_literal: true

# Configuration and contexts · 06 · Smith Island logger
#
# Teaches:
# - config.logger is a Logger the test can read, without RUBYLLM_DEBUG.
# - Setting logger overrides log_file and log_level on Configuration.
# - RubyLLM.logger is memoized from the first Logger it builds, so a later
#   configure does not take effect until that memo is cleared.

require "logger"
require "stringio"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../paid_openrouter"

module SmithIslandLogger
  # The keeper at Smith Island Light writes the weather round through a
  # logger the watch can read back, instead of $stdout.
  class WeatherLogger
    INSTRUCTIONS = <<~TEXT.strip
      You are the keeper at Smith Island Light.
      Read the weather round back in two short sentences.
      Use only the clipboard in the question.
      Include SE 15 and 29.92.
      Do not forecast tomorrow.
    TEXT

    ROUND_QUESTION = <<~TEXT.strip
      Keeper's weather round, Smith Island Light, Wednesday 14 October 2026, 06:00.
      The relief may later compare the clipboard with https://www.ndbc.noaa.gov/.
      Wind: SE 15 knots.
      Visibility: 4 miles in fog.
      Barometer: 29.92 inches and steady.
      Read the round back for the log.
    TEXT

    Result = Struct.new(
      :round,
      :log_text,
      :memoized_same_object,
      :after_clear_uses_station_logger,
      keyword_init: true
    )

    def self.conduct
      log = StringIO.new
      station_logger = Logger.new(log)
      station_logger.level = Logger::DEBUG
      station_logger.formatter = proc { |_severity, _time, _progname, message| "#{message}\n" }

      configure(station_logger)
      previous_logger = RubyLLM.logger
      memoized_same_object = previous_logger.equal?(station_logger)
      RubyLLM.instance_variable_set(:@logger, nil) unless previous_logger.equal?(station_logger)
      after_clear = RubyLLM.logger.equal?(station_logger)

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      round = chat.ask(ROUND_QUESTION)

      Result.new(
        round: round.content,
        log_text: log.string,
        memoized_same_object: memoized_same_object,
        after_clear_uses_station_logger: after_clear
      )
    ensure
      RubyLLM.instance_variable_set(:@logger, nil)
    end

    def self.open_chat
      ConfigurationPaidOpenrouter.prepare(
        RubyLLM.chat(**ConfigurationPaidOpenrouter.chat_args)
      )
    end

    def self.configure(station_logger)
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openrouter)
        config.max_retries = 0
        config.request_timeout = 120
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = station_logger
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "weather_logger") do
    result = SmithIslandLogger::WeatherLogger.conduct
  end

  puts result.round
  puts
  puts result.log_text.lines.grep(/POST|chat/).first
end
