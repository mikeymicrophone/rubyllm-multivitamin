# frozen_string_literal: true

# Streaming · 02 · Cape Disappointment blast log
#
# Teaches:
# - Write each spoken chunk to a terminal as it arrives.
# - with_thinking(false) keeps the log to the spoken card.
# - The cassette stores the SSE body, and a second pass replays the same pieces.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module CapeDisappointmentBlastLog
  # The horn watch at Cape Disappointment calls the posted card into the
  # log as the chunks arrive. Two passes of the same card must match.
  class BlastLog
    INSTRUCTIONS = <<~TEXT.strip
      You are the foghorn watch at Cape Disappointment Light.
      Call the posted card in two short sentences.
      Use only the card in the question.
      Name the blast of 2 seconds and the silence of 18 seconds.
      Do not invent a compressor pressure.
    TEXT

    CARD_QUESTION = <<~TEXT.strip
      Foghorn card posted Wednesday 14 October 2026 at Cape Disappointment.
      Station notes: https://www.nps.gov/places/cape-disappointment-lighthouse.htm
      Visibility is under 1 mile, so the horn is running.
      Blast 2 seconds. Silent 18 seconds.
      Call the card into the log.
    TEXT

    Result = Struct.new(:passes, keyword_init: true)

    Pass = Struct.new(:speech, :pieces, :thinking_chunks, keyword_init: true)

    def self.conduct(horn_log)
      configure

      passes = Array.new(2) { call_card(horn_log) }
      Result.new(passes: passes)
    end

    def self.call_card(horn_log)
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      # This model streams reasoning before the words unless thinking is off.
      # The log is the spoken card, so the reasoning chunks stay off the horn.
      chat.with_thinking(false)

      pieces = []
      thinking_chunks = 0
      message = chat.ask(CARD_QUESTION) do |chunk|
        thinking_chunks += 1 if chunk.thinking&.text
        piece = chunk.content.to_s
        next if piece.empty?

        pieces << piece
        horn_log.write(piece)
        horn_log.flush if horn_log.respond_to?(:flush)
      end

      Pass.new(speech: message.content, pieces: pieces, thinking_chunks: thinking_chunks)
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
  Multivitamin::Cassettes.play(__dir__, "blast_log") do
    result = CapeDisappointmentBlastLog::BlastLog.conduct($stdout)
  end

  puts
end
