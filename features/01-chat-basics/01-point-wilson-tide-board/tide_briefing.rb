# frozen_string_literal: true

# Chat basics · 01 · Point Wilson tide board
#
# Teaches:
# - RubyLLM.chat opens a conversation on a named model and provider.
# - with_instructions sets the system prompt, and the next turns keep it.
# - ask sends the transcript and returns a RubyLLM::Message.
# - A second ask on the same chat sends the earlier turns back.
# - finish_reason, tokens, and cost are read off that message.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PointWilsonTideBoard
  # The incoming watch at Point Wilson reads two questions off the posted
  # tide board. The clerk's instructions stay on the chat for both.
  class TideBriefing
    INSTRUCTIONS = <<~TEXT.strip
      You are the tide clerk at Point Wilson Light Station on Admiralty Inlet.
      Brief the incoming watch in short sentences.
      Use only the tide board in the question.
      Name the boats Alden and Retort.
      Do not invent tide heights.
    TEXT

    BOARD_QUESTION = <<~TEXT.strip
      Tide board posted for Wednesday 14 October 2026 at Point Wilson.
      Low water 06:42, 0.4 ft above MLLW.
      High water 12:18, 8.1 ft.
      Low water 18:55, 2.6 ft.
      The foghorn tender Alden needs 6.0 ft at the float to clear the kelp ledge.
      The cannery tender Retort, up from the Anacortes cannery, can use the float at 3.5 ft.
      The Fresnel lens crew is in the lens cabinet until 09:30 and must not be hailed while the lamp is open.
      When can Alden leave the float this morning, and when can Retort?
    TEXT

    LENS_QUESTION = "The lens cabinet stays open until 09:30. Should the watch hail the lens crew before Alden sails?"

    Result = Struct.new(
      :opening,
      :follow_up,
      :roles,
      :opening_finish,
      :follow_up_finish,
      :opening_input_tokens,
      :opening_output_tokens,
      :follow_up_input_tokens,
      :follow_up_output_tokens,
      :opening_cost,
      :follow_up_cost,
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

      opening = chat.ask(BOARD_QUESTION)
      follow_up = chat.ask(LENS_QUESTION)

      Result.new(
        opening: opening.content,
        follow_up: follow_up.content,
        roles: chat.messages.map(&:role),
        opening_finish: opening.finish_reason,
        follow_up_finish: follow_up.finish_reason,
        opening_input_tokens: opening.tokens.input,
        opening_output_tokens: opening.tokens.output,
        follow_up_input_tokens: follow_up.tokens.input,
        follow_up_output_tokens: follow_up.tokens.output,
        opening_cost: opening.cost.total,
        follow_up_cost: follow_up.cost.total
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
  Multivitamin::Cassettes.play(__dir__, "tide_briefing") do
    result = PointWilsonTideBoard::TideBriefing.conduct
  end

  puts result.opening
  puts
  puts result.follow_up
end
