# frozen_string_literal: true

# Audio transcription · 06 · Dungeness Spit SRT card
#
# Teaches:
# - format: "srt" asks whisper-1 for a subtitle card.
# - transcription.text is the SRT string, not a JSON object.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module DungenessSpitSrt
  # The chart desk at Dungeness Spit wants the bell-buoy move as a subtitle
  # card the watch can paste into the notice log.
  class SpitCard
    RECORDING = File.expand_path("dungeness-spit-buoy.mp3", __dir__)

    Result = Struct.new(:text, :model, keyword_init: true)

    def self.conduct
      configure
      tape = RubyLLM.transcribe(
        RECORDING,
        **Multivitamin::Models.transcribe(model: Multivitamin::Models::OPENAI_TRANSCRIBE_WHISPER),
        format: "srt"
      )

      Result.new(text: tape.text, model: tape.model)
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
  Multivitamin::Cassettes.play(__dir__, "dungeness_srt") do
    result = DungenessSpitSrt::SpitCard.conduct
  end

  puts result.text
end
