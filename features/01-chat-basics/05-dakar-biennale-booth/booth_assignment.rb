# frozen_string_literal: true

# Chat basics · 05 · Dakar Biennale booth assignment
#
# Teaches:
# - The reply can name one booth while chat.messages still holds the rest.
# - Inspecting messages is how the registrar checks the transcript,
#   not a second copy of the hanging board kept beside the chat.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module DakarBiennaleBooths
  # The night registrar at Dak'Art has four lines on the board
  # and only one artist that needs a booth assigned in the reply.
  class BoothAssignment
    INSTRUCTIONS = <<~TEXT.strip
      You are the night registrar at the Dakar Biennale hanging floor.
      Answer in two short sentences.
      Use only the hanging board in the question.
      The first sentence names the booth you assign.
      Do not drop artists from the conversation just because the reply names one of them.
    TEXT

    BOARD_QUESTION = <<~TEXT.strip
      Hanging board for Wednesday night 14 October 2026.
      Biennale office, Village des Arts, Dakar, https://biennaledakar.org/.
      G-14: painter Chioma Okeke, 42 canvases, needs track lighting, assign here if the booth is open.
      H-2: sculptor Mateo Ruiz, 36 crates, wet-room water only, already installed and staying.
      Loading dock: video artist Yuki Tanaka, taking crates, not a booth, leave when the van is empty.
      J-7: closed for floor epoxy, do not assign.
      Where do you put Chioma for the week?
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
  Multivitamin::Cassettes.play(__dir__, "booth_assignment") do
    result = DakarBiennaleBooths::BoothAssignment.conduct
  end

  puts result.assignment
  puts
  result.roles.each_with_index do |role, index|
    puts "#{index} #{role}"
  end
end
