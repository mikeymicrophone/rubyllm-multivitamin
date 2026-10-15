# frozen_string_literal: true

# Text to speech · 01 · Fort Worden welcome hail
#
# Teaches:
# - RubyLLM.speak returns a RubyLLM::Speech.
# - model: and provider: select tts-1 on OpenAI.
# - The omitted voice: is sent as alloy. The omitted format: is mp3.
# - mime_type is audio/mpeg.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module FortWordenWelcomeHail
  # The incoming watch at Fort Worden wants a short hail for the fog on
  # the spit before Alden clears the kelp ledge.
  class WelcomeHail
    HAIL = "Fort Worden hail. Fog on the spit."

    Result = Struct.new(:speech, :model, :voice, :format, :mime_type, keyword_init: true)

    def self.conduct
      configure
      speech = RubyLLM.speak(HAIL, **Multivitamin::Models.speech)

      Result.new(
        speech: speech,
        model: speech.model,
        voice: speech.voice,
        format: speech.format,
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
  Multivitamin::Cassettes.play(__dir__, "welcome_hail") do
    result = FortWordenWelcomeHail::WelcomeHail.conduct
  end

  puts result.model
  puts result.voice
  puts result.mime_type
end
