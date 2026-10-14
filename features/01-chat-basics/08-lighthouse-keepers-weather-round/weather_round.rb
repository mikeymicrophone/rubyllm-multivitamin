# frozen_string_literal: true

# Chat basics · 08 · Lighthouse keeper's weather round
#
# Teaches:
# - stopped? is how the keeper knows the round finished.
# - The check is the finish reason, not a search through the prose for "stop".
# - A factual clipboard is a single ask with instructions to copy, not forecast.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PatosIslandWeather
  # The relief at Patos Island Light reads the keeper's clipboard back.
  # The round is done when the message stopped, whatever the sentences say.
  class WeatherRound
    INSTRUCTIONS = <<~TEXT.strip
      You are the relief keeper at Patos Island Light.
      Read the weather round back in four short sentences, one fact each.
      Use only the clipboard in the question.
      Do not forecast tomorrow and do not add a sea condition that is not written.
      Include the wind, the visibility, the barometer, and the sea.
    TEXT

    ROUND_QUESTION = <<~TEXT.strip
      Keeper's weather round, Patos Island Light, Wednesday 14 October 2026, 06:00.
      The relief may later compare the clipboard with https://www.ndbc.noaa.gov/.
      This round is the clipboard, not the buoy feed:
      Wind: SE 15 knots.
      Visibility: 4 miles in fog.
      Barometer: 29.92 inches and steady.
      Sea: 2 feet.
      Read the round back for the log.
    TEXT

    Result = Struct.new(
      :round,
      :stopped,
      :finish_reason,
      :roles,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = RubyLLM.chat(
        model: Multivitamin::Models::CHAT,
        provider: :openrouter,
        assume_model_exists: true
      )
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)

      reply = chat.ask(ROUND_QUESTION)

      Result.new(
        round: reply.content,
        stopped: reply.stopped?,
        finish_reason: reply.finish_reason,
        roles: chat.messages.map(&:role)
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        config.openrouter_api_key = ENV.fetch("OPENROUTER_API_KEY")
        config.openrouter_app_url = "https://github.com/mikeymicrophone/rubyllm-multivitamin"
        config.openrouter_app_name = "RubyLLM Multivitamin"
        # Chat Completions emits a developer role unless this is set.
        # OpenRouter expects system. The flag is shared with OpenAI's formatter.
        config.openai_use_system_role = true
        config.max_retries = 0
        config.request_timeout = 120
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "weather_round") do
    result = PatosIslandWeather::WeatherRound.conduct
  end

  puts result.round
  puts
  puts "stopped=#{result.stopped} finish=#{result.finish_reason}"
end
