# frozen_string_literal: true

# Instructions and history · 13 · Admiralty Inlet watch reset
#
# Teaches:
# - Assigning messages = [] resets the conversation on the same chat.
# - New with_instructions after the reset is the only system prompt.
# - The next ask does not see the overnight board.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AdmiraltyInletWatchReset
  # The overnight clerk at Point Wilson briefs the horn, then the morning
  # relief resets the transcript, posts new orders, and asks when Alden
  # can leave the kelp-ledge float.
  class WatchReset
    NIGHT_ORDERS = <<~TEXT.strip
      You are the overnight tide clerk at Point Wilson Light Station on Admiralty Inlet.
      These are the overnight standing orders.
      Answer in two short sentences.
      The first sentence starts with Yes or No.
      Name whether the horn is running.
      Do not invent a blast time.
    TEXT

    MORNING_ORDERS = <<~TEXT.strip
      You are the morning relief at Point Wilson Light Station on Admiralty Inlet.
      These are the morning standing orders.
      Answer in two short sentences.
      Name the clock time Alden leaves.
      Do not invent a tide height.
    TEXT

    NIGHT_QUESTION = <<~TEXT.strip
      Overnight board at Point Wilson, Wednesday night 14 October 2026.
      Tide reference: https://tidesandcurrents.noaa.gov/ station 9444900.
      Low water 07:05, 1.1 ft.
      Visibility 1 mile, so the horn is running.
      Blast 3 seconds, silent 27 seconds.
      Is the horn running?
    TEXT

    MORNING_QUESTION = <<~TEXT.strip
      Morning board at Point Wilson, Thursday 15 October 2026.
      Low water 06:42, 0.4 ft above MLLW.
      High water 12:18, 8.1 ft.
      The foghorn tender Alden clears the kelp ledge at 10:46.
      The lens cabinet is closed.
      When can Alden leave the float?
    TEXT

    Result = Struct.new(
      :night,
      :morning,
      :roles_after_reset,
      :roles,
      :night_finish,
      :morning_finish,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(NIGHT_ORDERS)
      chat.with_temperature(0.2)
      night = chat.ask(NIGHT_QUESTION)

      chat.messages = []
      chat.with_instructions(MORNING_ORDERS)
      roles_after_reset = chat.messages.map(&:role)
      morning = chat.ask(MORNING_QUESTION)

      Result.new(
        night: night.content,
        morning: morning.content,
        roles_after_reset: roles_after_reset,
        roles: chat.messages.map(&:role),
        night_finish: night.finish_reason,
        morning_finish: morning.finish_reason
      )
    end

    def self.open_chat
      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat
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
  Multivitamin::Cassettes.play(__dir__, "watch_reset") do
    result = AdmiraltyInletWatchReset::WatchReset.conduct
  end

  puts result.night
  puts
  puts result.morning
end
