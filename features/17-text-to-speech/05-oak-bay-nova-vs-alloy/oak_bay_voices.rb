# frozen_string_literal: true

# Text to speech · 05 · Oak Bay nova vs alloy
#
# Teaches:
# - Two speak calls with the same hail and different voice: values.
# - Each request names the voice that was asked for.
# - Both recordings stay on tts-1.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module OakBayNovaVsAlloy
  # The range keeper at Oak Bay files the same bearing hail in nova for
  # the front range and in alloy for the rear, so the packets can tell
  # which light is speaking.
  class OakBayVoices
    HAIL = "Oak Bay range. Alden on the bearing."

    Result = Struct.new(:nova_voice, :alloy_voice, :nova_model, :alloy_model, keyword_init: true)

    def self.conduct
      configure
      nova = RubyLLM.speak(HAIL, **Multivitamin::Models.speech(voice: "nova"))
      alloy = RubyLLM.speak(HAIL, **Multivitamin::Models.speech(voice: "alloy"))

      Result.new(
        nova_voice: nova.voice,
        alloy_voice: alloy.voice,
        nova_model: nova.model,
        alloy_model: alloy.model
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
  Multivitamin::Cassettes.play(__dir__, "oak_bay_voices") do
    result = OakBayNovaVsAlloy::OakBayVoices.conduct
  end

  puts result.nova_voice
  puts result.alloy_voice
end
