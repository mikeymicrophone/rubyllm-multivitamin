# frozen_string_literal: true

# Streaming · 04 · Neah Bay pilot ladder steps
#
# Teaches:
# - Ordered steps stay in order when a chunk ends mid-sentence.
# - The message returned after streaming is the assistant turn.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module NeahBayLadderSteps
  # The pilot boat off Neah Bay calls the ladder inspection in the order
  # the mate will write it: side ropes, wooden steps, spreaders, manropes.
  class LadderSteps
    INSTRUCTIONS = <<~TEXT.strip
      You are the mate on the pilot boat off Neah Bay.
      Call the four ladder checks in the order given, one short sentence each.
      Use only the inspection card.
      Keep the four names in that order: side ropes, wooden steps, spreaders, manropes.
    TEXT

    CARD_QUESTION = <<~TEXT.strip
      Pilot ladder inspection for Wednesday 14 October 2026, boarding off Neah Bay.
      Pilots: https://www.pspilots.org/
      1. Side ropes are manila, both sides, and the eyes are seized.
      2. Wooden steps are sound, with no cracked step in the lower four.
      3. Spreaders are fitted on the fifth step and stand square.
      4. Manropes run the full length and the pilot can hold them.
      Call the four checks in that order.
    TEXT

    Result = Struct.new(
      :speech,
      :pieces,
      :same_message,
      :role,
      :roles,
      :finish_reason,
      :stopped,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.with_thinking(false)

      pieces = []
      message = chat.ask(CARD_QUESTION) do |chunk|
        piece = chunk.content.to_s
        pieces << piece unless piece.empty?
      end

      Result.new(
        speech: message.content,
        pieces: pieces,
        same_message: chat.messages.last.equal?(message),
        role: message.role,
        roles: chat.messages.map(&:role),
        finish_reason: message.finish_reason,
        stopped: message.stopped?
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
        config.request_timeout = 180
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "ladder_steps") do
    result = NeahBayLadderSteps::LadderSteps.conduct
  end

  puts result.speech
end
