# frozen_string_literal: true

# Instructions and history · 09 · Hobart hydrometer message roles
#
# Teaches:
# - messages.map(&:role) is the transcript the model saw.
# - After one ask the roles are system, user, assistant.
# - Each message still has its own content.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module HobartHydrometerRoles
  # The still-house clerk at a family whisky warehouse in Hobart reads
  # the hydrometer round back from chat.messages, role by role, after
  # posting the glass.
  class HydrometerRoles
    INSTRUCTIONS = <<~TEXT.strip
      You are the still-house clerk at the Chen family whisky warehouse in Hobart.
      Answer in two short sentences.
      Quote the hydrometer reading exactly.
      Do not invent a proof.
    TEXT

    GLASS_QUESTION = <<~TEXT.strip
      Warehouse round at the Chen still-house, Hobart, Wednesday 14 October 2026, 08:00.
      Warehouse page: https://www.sullivanscove.com/
      Hydrometer 29.92 percent, falling.
      The glass is cracked at the seven o'clock mark.
      Cask loft 8 C, visibility down the aisle 7 metres.
      What is the hydrometer reading, and is it falling?
    TEXT

    Result = Struct.new(
      :round,
      :roles,
      :system_content,
      :user_content,
      :assistant_content,
      :assistant_role,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      round = chat.ask(GLASS_QUESTION)

      Result.new(
        round: round.content,
        roles: chat.messages.map(&:role),
        system_content: chat.messages[0].content,
        user_content: chat.messages[1].content,
        assistant_content: chat.messages[2].content,
        assistant_role: chat.messages[2].role
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
  Multivitamin::Cassettes.play(__dir__, "hydrometer_roles") do
    result = HobartHydrometerRoles::HydrometerRoles.conduct
  end

  puts "#{result.roles.join(' / ')}"
  puts
  puts result.round
end
