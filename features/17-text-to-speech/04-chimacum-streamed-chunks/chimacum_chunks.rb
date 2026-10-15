# frozen_string_literal: true

# Text to speech · 04 · Chimacum streamed chunks
#
# Teaches:
# - A block on RubyLLM.speak yields RubyLLM::SpeechChunk objects.
# - Each chunk has data, format, mime_type, and to_blob.
# - Joined chunk bytes equal the Speech the call returns.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module ChimacumStreamedChunks
  # The creek watch at Chimacum wants the ebb hail on the loudspeaker as
  # the bytes arrive, then files the complete recording.
  class ChimacumChunks
    HAIL = "Chimacum creek. Ebb under the bridge."

    Result = Struct.new(:speech, :chunks, :joined, keyword_init: true)

    def self.conduct
      configure
      chunks = []
      speech = RubyLLM.speak(HAIL, **Multivitamin::Models.speech) do |chunk|
        chunks << chunk
      end

      Result.new(
        speech: speech,
        chunks: chunks,
        joined: chunks.map(&:to_blob).join
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 60
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "chimacum_chunks") do
    result = ChimacumStreamedChunks::ChimacumChunks.conduct
  end

  puts result.chunks.length
  puts result.joined.bytesize
end
