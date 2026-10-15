# frozen_string_literal: true

# Audio transcription · 10 · Mats Mats silent tape
#
# Teaches:
# - A silent recording still returns a Transcription.
# - text is empty. That is not ContentFilterError and not a missing tape.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module MatsMatsSilence
  # The Mats Mats Bay watch handed over a reel with the lid on the horn
  # mike. The desk still runs it so a blank tape is logged, not guessed.
  class SilentReel
    RECORDING = File.expand_path("mats-mats-silence.mp3", __dir__)

    Result = Struct.new(:text, :model, :blank, keyword_init: true)

    def self.conduct
      configure
      tape = RubyLLM.transcribe(RECORDING, **Multivitamin::Models.transcribe)

      Result.new(
        text: tape.text,
        model: tape.model,
        blank: tape.text.to_s.strip.empty?
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
  Multivitamin::Cassettes.play(__dir__, "mats_silence") do
    result = MatsMatsSilence::SilentReel.conduct
  end

  puts result.blank ? "(silent)" : result.text
end
