# frozen_string_literal: true

# Audio transcription · 05 · Morse Creek word timestamps
#
# Teaches:
# - timestamps: [:word, :segment] on whisper-1 asks for both granularities.
# - The request becomes verbose_json with timestamp_granularities.
# - words and segments are arrays of hashes with start and end.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module MorseCreekTimestamps
  # The sounding skiff off Morse Creek files a five-fathom soft-mud tape
  # so the Port Angeles desk can mark when each word was spoken.
  class CreekSounding
    RECORDING = File.expand_path("morse-creek-sounding.mp3", __dir__)

    Result = Struct.new(
      :text,
      :model,
      :duration,
      :words,
      :segments,
      keyword_init: true
    )

    def self.conduct
      configure
      tape = RubyLLM.transcribe(
        RECORDING,
        **Multivitamin::Models.transcribe(model: Multivitamin::Models::OPENAI_TRANSCRIBE_WHISPER),
        timestamps: %i[word segment]
      )

      Result.new(
        text: tape.text,
        model: tape.model,
        duration: tape.duration,
        words: tape.words,
        segments: tape.segments
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
  Multivitamin::Cassettes.play(__dir__, "morse_timestamps") do
    result = MorseCreekTimestamps::CreekSounding.conduct
  end

  puts result.text
  puts "words #{result.words&.length} segments #{result.segments&.length} duration #{result.duration}"
end
