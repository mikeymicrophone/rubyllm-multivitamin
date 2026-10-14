# frozen_string_literal: true

# Chat basics · 05 · Friday Harbor berth assignment
#
# Teaches:
# - The reply can name one berth while chat.messages still holds the rest.
# - Inspecting messages is how the harbormaster checks the transcript,
#   not a second copy of the board kept beside the chat.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module FridayHarborBerths
  # The night harbormaster at Friday Harbor has four lines on the board
  # and only one boat that needs a berth assigned in the reply.
  class SlipAssignment
    INSTRUCTIONS = <<~TEXT.strip
      You are the night harbormaster at the Port of Friday Harbor marina.
      Answer in two short sentences.
      Use only the berth board in the question.
      The first sentence names the berth you assign.
      Do not drop boats from the conversation just because the reply names one of them.
    TEXT

    BOARD_QUESTION = <<~TEXT.strip
      Berth board for Wednesday night 14 October 2026.
      Marina office, 204 Front Street, Friday Harbor, https://www.portfridayharbor.org/.
      G-14: foghorn tender Alden, 42 feet, needs shore power, assign here if the berth is open.
      H-2: cannery tender Retort, 36 feet, water only, already tied and staying.
      Fuel float: seiner Cape Flattery, taking diesel, not a berth, cast off when the tanks are full.
      J-7: closed for piling work, do not assign.
      Where do you put Alden for the night?
    TEXT

    Result = Struct.new(
      :assignment,
      :roles,
      :user_board,
      :message_count,
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

      reply = chat.ask(BOARD_QUESTION)
      user_turn = chat.messages.find { |message| message.role == :user }

      Result.new(
        assignment: reply.content,
        roles: chat.messages.map(&:role),
        user_board: user_turn.content,
        message_count: chat.messages.length
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
  Multivitamin::Cassettes.play(__dir__, "slip_assignment") do
    result = FridayHarborBerths::SlipAssignment.conduct
  end

  puts result.assignment
  puts
  result.roles.each_with_index do |role, index|
    puts "#{index} #{role}"
  end
end
