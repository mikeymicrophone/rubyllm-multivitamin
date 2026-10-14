# frozen_string_literal: true

# Chat basics · 09 · Bremerton dry dock gate schedule
#
# Teaches:
# - Reusing a chat keeps the gate schedule, so a short follow-up still works.
# - A fresh chat that only hears the follow-up does not have the schedule.
# - The same question string is a different job once the transcript changes.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module BremertonHaulOut
  # The yard clerk at Bremerton Marina answers "And Retort?" twice:
  # once on the chat that already has the gate schedule, and once on a
  # new chat that was never shown the board.
  class GateSchedule
    INSTRUCTIONS = <<~TEXT.strip
      You are the yard clerk at Bremerton Marina, Port of Bremerton.
      Answer in one or two short sentences.
      Use only the gate schedule pasted in this chat.
      If this chat has no gate schedule, reply exactly:
      The gate log was not handed over.
      Do not invent flood times.
    TEXT

    SCHEDULE_QUESTION = <<~TEXT.strip
      Haul-out gate schedule posted at Bremerton Marina for Wednesday 14 October 2026.
      The marina office is the Port of Bremerton, https://www.portofbremerton.org/.
      Gate opens 06:30.
      Dock floods 09:15 for the seiner Cape Flattery.
      Gate closes 11:40.
      Afternoon flood 15:05 for the cannery tender Retort.
      When does the dock flood for Cape Flattery?
    TEXT

    RETORT_QUESTION = "And the tender Retort?"

    Result = Struct.new(
      :flattery,
      :retort_on_the_same_chat,
      :retort_on_a_fresh_chat,
      :reused_roles,
      :fresh_roles,
      :fresh_user_text,
      :reused_still_has_schedule,
      keyword_init: true
    )

    def self.conduct
      configure

      reused = open_chat
      reused.with_instructions(INSTRUCTIONS)
      reused.with_temperature(0.2)
      flattery = reused.ask(SCHEDULE_QUESTION)
      retort_same = reused.ask(RETORT_QUESTION)

      fresh = open_chat
      fresh.with_instructions(INSTRUCTIONS)
      fresh.with_temperature(0.2)
      retort_fresh = fresh.ask(RETORT_QUESTION)

      Result.new(
        flattery: flattery.content,
        retort_on_the_same_chat: retort_same.content,
        retort_on_a_fresh_chat: retort_fresh.content,
        reused_roles: reused.messages.map(&:role),
        fresh_roles: fresh.messages.map(&:role),
        fresh_user_text: fresh.messages.find { |message| message.role == :user }.content,
        reused_still_has_schedule: reused.messages.any? { |message|
          message.role == :user && message.content.include?("Cape Flattery")
        }
      )
    end

    def self.open_chat
      RubyLLM.chat(
        model: Multivitamin::Models::CHAT,
        provider: :openrouter,
        assume_model_exists: true
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
  Multivitamin::Cassettes.play(__dir__, "gate_schedule") do
    result = BremertonHaulOut::GateSchedule.conduct
  end

  puts result.flattery
  puts
  puts "same chat: #{result.retort_on_the_same_chat}"
  puts
  puts "fresh chat: #{result.retort_on_a_fresh_chat}"
end
