# frozen_string_literal: true

# Instructions and history · 12 · Juan de Fuca overnight log compacted
#
# Teaches:
# - A long overnight log can be summarized on the same chat.
# - messages= keeps four turns: system, first notice, summary question,
#   and the summary.
# - The next request drops the middle notices.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module JuanDeFucaLogCompact
  # The mate on chart 18465 logs three overnight notices, asks for a
  # two-sentence handover, then keeps only four turns before the relief
  # asks about buoy DH.
  class LogCompact
    INSTRUCTIONS = <<~TEXT.strip
      You are the mate correcting NOAA chart 18465 on the Strait of Juan de Fuca.
      Answer in two short sentences.
      Use only the notices that are still in this chat.
      Do not invent a latitude or a longitude.
    TEXT

    DH_NOTICE = <<~TEXT.strip
      Overnight notice 1, Wednesday 14 October 2026.
      Chart catalog: https://www.nauticalcharts.noaa.gov/
      NOAA chart 18465. Dungeness Spit lighted bell buoy DH is moved 300 yards
      northwest of the symbol printed on the chart.
      Record the DH move.
    TEXT

    RACE_NOTICE = <<~TEXT.strip
      Overnight notice 2.
      Race Rocks visibility is 2 miles in haze. The Race Rocks horn is running.
      Record the visibility.
    TEXT

    DUNGENESS_NOTICE = <<~TEXT.strip
      Overnight notice 3.
      New Dungeness sector is unchanged. The fourth-order lens still covers
      the spit as printed. Record the sector.
    TEXT

    SUMMARY_QUESTION = "Write a two-sentence handover of every notice still in this chat."

    RELIEF_QUESTION = "The relief asks whether DH is still on the printed symbol."

    Result = Struct.new(
      :dh,
      :race,
      :dungeness,
      :summary,
      :relief,
      :roles_before_compact,
      :roles_after_compact,
      :roles,
      :kept_count,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      dh = chat.ask(DH_NOTICE)
      race = chat.ask(RACE_NOTICE)
      dungeness = chat.ask(DUNGENESS_NOTICE)
      summary = chat.ask(SUMMARY_QUESTION)
      roles_before_compact = chat.messages.map(&:role)

      system = chat.messages.first
      opening_user = chat.messages[1]
      summary_user = chat.messages[-2]
      summary_assistant = chat.messages[-1]
      chat.messages = [system, opening_user, summary_user, summary_assistant]
      roles_after_compact = chat.messages.map(&:role)
      kept_count = chat.messages.length
      relief = chat.ask(RELIEF_QUESTION)

      Result.new(
        dh: dh.content,
        race: race.content,
        dungeness: dungeness.content,
        summary: summary.content,
        relief: relief.content,
        roles_before_compact: roles_before_compact,
        roles_after_compact: roles_after_compact,
        roles: chat.messages.map(&:role),
        kept_count: kept_count
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
  Multivitamin::Cassettes.play(__dir__, "log_compact") do
    result = JuanDeFucaLogCompact::LogCompact.conduct
  end

  puts result.summary
  puts
  puts result.relief
end
