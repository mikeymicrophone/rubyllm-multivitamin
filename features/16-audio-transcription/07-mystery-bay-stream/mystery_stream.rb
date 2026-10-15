# frozen_string_literal: true

# Audio transcription · 07 · Mystery Bay streamed deltas
#
# Teaches:
# - A block on transcribe yields TranscriptionChunk objects.
# - delta? chunks carry text to append. done? is the final event.
# - The call still returns the completed Transcription.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module MysteryBayStream
  # The oyster-float watch at Mystery Bay, on Marrowstone Island, streams
  # the skiff tape so the Port Townsend desk can post each phrase as it
  # lands.
  class SkiffStream
    RECORDING = File.expand_path("mystery-bay-skiff.mp3", __dir__)

    Chunk = Struct.new(:type, :delta, :delta_flag, :done_flag, keyword_init: true)
    Result = Struct.new(:text, :model, :chunks, :joined_deltas, keyword_init: true)

    def self.conduct
      configure
      chunks = []
      tape = RubyLLM.transcribe(RECORDING, **Multivitamin::Models.transcribe) do |chunk|
        chunks << Chunk.new(
          type: chunk.type,
          delta: chunk.delta,
          delta_flag: chunk.delta?,
          done_flag: chunk.done?
        )
      end

      Result.new(
        text: tape.text,
        model: tape.model,
        chunks: chunks,
        joined_deltas: chunks.select(&:delta_flag).map(&:delta).join
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
  Multivitamin::Cassettes.play(__dir__, "mystery_stream") do
    result = MysteryBayStream::SkiffStream.conduct
  end

  puts result.joined_deltas
  puts result.text
end
