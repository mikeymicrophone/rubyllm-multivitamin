# frozen_string_literal: true

# Instructions and history · 08 · Bremerton afternoon relief replaces orders
#
# Teaches:
# - A second with_instructions replaces every system message.
# - The replacement is appended at the end of chat.messages.
# - The next request carries the new system text, not the morning orders.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module BremertonAfternoonRelief
  # The morning gate clerk at the Port of Bremerton logs the shut gate,
  # then the afternoon relief replaces those orders before writing the
  # crew note.
  class AfternoonRelief
    MORNING_ORDERS = <<~TEXT.strip
      You are the morning gate clerk at the Port of Bremerton dry dock.
      These are the morning standing orders.
      Answer in two short sentences.
      The first sentence starts with Yes or No.
      Name the sill in feet.
      Do not invent a sill depth.
    TEXT

    AFTERNOON_ORDERS = <<~TEXT.strip
      You are the afternoon relief at the Port of Bremerton dry dock.
      These are the afternoon standing orders.
      Answer in two short sentences.
      The first sentence starts with Afternoon.
      Name the sill in feet from this chat.
      Do not invent a sill depth.
    TEXT

    GATE_QUESTION = <<~TEXT.strip
      Wednesday 14 October 2026, morning, Port of Bremerton dry dock.
      Gate office: https://www.portofbremerton.org/
      The gate is shut. Water over the sill is 18.4 ft.
      Is the gate shut, and what is the sill?
    TEXT

    NOTE_QUESTION = "Write the afternoon crew note. Keep the sill from this chat."

    Result = Struct.new(
      :morning,
      :afternoon,
      :roles_after_replace,
      :roles,
      :system_after_replace,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(MORNING_ORDERS)
      chat.with_temperature(0.2)
      morning = chat.ask(GATE_QUESTION)

      chat.with_instructions(AFTERNOON_ORDERS)
      roles_after_replace = chat.messages.map(&:role)
      system_after_replace = chat.messages.select { |message| message.role == :system }.map(&:content)
      afternoon = chat.ask(NOTE_QUESTION)

      Result.new(
        morning: morning.content,
        afternoon: afternoon.content,
        roles_after_replace: roles_after_replace,
        roles: chat.messages.map(&:role),
        system_after_replace: system_after_replace
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
  Multivitamin::Cassettes.play(__dir__, "afternoon_relief") do
    result = BremertonAfternoonRelief::AfternoonRelief.conduct
  end

  puts result.morning
  puts
  puts result.afternoon
end
