# frozen_string_literal: true

# Text to speech · 02 · Hadlock slip announcement voice
#
# Teaches:
# - voice: is sent on the audio/speech payload.
# - Speech#voice is the voice that was requested.
# - nova is a named OpenAI voice, not the alloy default.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module HadlockSlipAnnouncementVoice
  # The slip clerk at Port Hadlock wants the inbound announcement in nova
  # so the apron can tell it from the alloy range hail.
  class SlipVoice
    HAIL = "Hadlock slip four. Khutzeymateen inbound."

    Result = Struct.new(:voice, :model, :mime_type, keyword_init: true)

    def self.conduct
      configure
      speech = RubyLLM.speak(HAIL, **Multivitamin::Models.speech(voice: "nova"))

      Result.new(
        voice: speech.voice,
        model: speech.model,
        mime_type: speech.mime_type
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
  Multivitamin::Cassettes.play(__dir__, "slip_voice") do
    result = HadlockSlipAnnouncementVoice::SlipVoice.conduct
  end

  puts result.voice
  puts result.model
end
