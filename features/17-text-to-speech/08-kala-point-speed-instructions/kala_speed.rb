# frozen_string_literal: true

# Text to speech · 08 · Kala Point speed instructions
#
# Teaches:
# - provider_options: merges OpenAI instructions and speed onto the payload.
# - Those keys sit beside model, input, and voice.
# - tts-1 accepts the fields. The clip stays short.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module KalaPointSpeedInstructions
  # The bluff watch at Kala Point wants the hail spoken slowly, with a
  # calm delivery, so the packets in Port Townsend Bay can copy it.
  class KalaSpeed
    HAIL = "Kala Point. Slow the hail."
    INSTRUCTIONS = "Speak slowly, as a calm bluff watch copying a card."

    Result = Struct.new(:model, :voice, :format, keyword_init: true)

    def self.conduct
      configure
      speech = RubyLLM.speak(
        HAIL,
        **Multivitamin::Models.speech(
          provider_options: {
            instructions: INSTRUCTIONS,
            speed: 0.85
          }
        )
      )

      Result.new(
        model: speech.model,
        voice: speech.voice,
        format: speech.format
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
  Multivitamin::Cassettes.play(__dir__, "kala_speed") do
    result = KalaPointSpeedInstructions::KalaSpeed.conduct
  end

  puts result.model
  puts result.format
end
