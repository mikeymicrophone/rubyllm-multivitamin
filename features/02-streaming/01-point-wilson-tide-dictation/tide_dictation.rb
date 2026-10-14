# frozen_string_literal: true

# Streaming · 01 · Point Wilson tide dictation
#
# Teaches:
# - ask with a block yields a RubyLLM::Chunk, and Chunk is a Message.
# - The model id is chunk.model. Token counts stay nil until the usage chunk.
# - Reasoning arrives as chunks whose content is empty and whose thinking
#   holds the delta. The joined speech matches the returned message.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PointWilsonTideDictation
  # The tide clerk at Point Wilson reads the posted board into the watch
  # phone. The block hears every chunk; the returned message is the note.
  class TideDictation
    INSTRUCTIONS = <<~TEXT.strip
      You are the tide clerk at Point Wilson Light Station on Admiralty Inlet.
      Dictate the board in two short sentences.
      Use only the board in the question.
      Name the tender Alden and the time 10:46.
      Do not invent a tide height.
    TEXT

    BOARD_QUESTION = <<~TEXT.strip
      Tide board posted for Wednesday 14 October 2026 at Point Wilson.
      Station page: https://tidesandcurrents.noaa.gov/stationhome.html?id=9444900
      Low water 06:42, 0.4 ft above MLLW.
      High water 12:18, 8.1 ft.
      The foghorn tender Alden needs 6.0 ft at the float and can leave at 10:46.
      Dictate that departure for the incoming watch.
    TEXT

    ChunkNote = Struct.new(
      :content,
      :thinking,
      :model_id,
      :input_tokens,
      :output_tokens,
      :thinking_tokens,
      :finish_reason,
      :chunk,
      keyword_init: true
    )

    Result = Struct.new(
      :speech,
      :thinking,
      :model_id,
      :finish_reason,
      :input_tokens,
      :output_tokens,
      :thinking_tokens,
      :roles,
      :notes,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)

      notes = []
      message = chat.ask(BOARD_QUESTION) do |chunk|
        notes << ChunkNote.new(
          content: chunk.content,
          thinking: chunk.thinking&.text,
          model_id: chunk.model,
          input_tokens: chunk.tokens.input,
          output_tokens: chunk.tokens.output,
          thinking_tokens: chunk.tokens.thinking,
          finish_reason: chunk.finish_reason,
          chunk: chunk.is_a?(RubyLLM::Chunk)
        )
      end

      Result.new(
        speech: message.content,
        thinking: message.thinking&.text,
        model_id: message.model,
        finish_reason: message.finish_reason,
        input_tokens: message.tokens.input,
        output_tokens: message.tokens.output,
        thinking_tokens: message.tokens.thinking,
        roles: chat.messages.map(&:role),
        notes: notes
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
  Multivitamin::Cassettes.play(__dir__, "tide_dictation") do
    result = PointWilsonTideDictation::TideDictation.conduct
  end

  puts result.speech
end
