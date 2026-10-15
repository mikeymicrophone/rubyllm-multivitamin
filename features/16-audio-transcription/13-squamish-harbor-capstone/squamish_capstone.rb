# frozen_string_literal: true

# Audio transcription · 13 · Squamish Harbor watch tape capstone
#
# Teaches:
# - prompt: and timestamps: together on whisper-1.
# - words and segments stay on the Transcription after the chat turn.
# - chat.ask writes the posted card from the tape, including 10:46.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module SquamishHarborCapstone
  # The outgoing watch at Squamish Harbor, inside Hood Canal, files the
  # overnight tape with the kelp-ledge vocabulary and word times, then
  # asks the relief clerk to post the card.
  class WatchTape
    RECORDING = File.expand_path("squamish-harbor-watch.mp3", __dir__)
    VOCABULARY = "Squamish Harbor, Alden, kelp ledge, MLLW."

    INSTRUCTIONS = <<~TEXT.strip
      You are the relief clerk at Squamish Harbor on Hood Canal.
      Write two short sentences for the incoming watch.
      Use only the tape. Name Alden. Keep 10:46 if the tape has it.
      Do not invent a tide height.
    TEXT

    Result = Struct.new(
      :tape_text,
      :brief,
      :roles,
      :words,
      :segments,
      :duration,
      :tape_model,
      keyword_init: true
    )

    def self.conduct
      configure
      tape = RubyLLM.transcribe(
        RECORDING,
        **Multivitamin::Models.transcribe(model: Multivitamin::Models::OPENAI_TRANSCRIBE_WHISPER),
        prompt: VOCABULARY,
        timestamps: %i[word segment]
      )
      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      brief = chat.ask("Post the watch card from this tape:\n#{tape.text}")

      Result.new(
        tape_text: tape.text,
        brief: brief.content,
        roles: chat.messages.map(&:role),
        words: tape.words,
        segments: tape.segments,
        duration: tape.duration,
        tape_model: tape.model
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
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
  Multivitamin::Cassettes.play(__dir__, "squamish_capstone") do
    result = SquamishHarborCapstone::WatchTape.conduct
  end

  puts result.tape_text
  puts
  puts result.brief
end
