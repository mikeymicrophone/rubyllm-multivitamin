# frozen_string_literal: true

# Text to speech · 06 · Kinney Point context speak
#
# Teaches:
# - ctx.speak uses the context's default_speech_model.
# - The global default_speech_model is left as it was.
# - ctx.speak returns the same Speech shape as RubyLLM.speak.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module KinneyPointContextSpeak
  # The flood watch at Kinney Point on Marrowstone Island speaks through
  # a tenant context so the spit desk does not inherit the cheap tts-1
  # default.
  class KinneyContext
    HAIL = "Kinney Point. Marrowstone flood."

    Result = Struct.new(
      :context_model,
      :context_voice,
      :context_mime,
      :global_default,
      :context_default,
      keyword_init: true
    )

    def self.conduct
      configure
      marrowstone = RubyLLM.context do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.default_speech_model = Multivitamin::Models::OPENAI_SPEECH
      end

      speech = marrowstone.speak(HAIL, provider: :openai)

      Result.new(
        context_model: speech.model,
        context_voice: speech.voice,
        context_mime: speech.mime_type,
        global_default: RubyLLM.config.default_speech_model,
        context_default: marrowstone.config.default_speech_model
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
  Multivitamin::Cassettes.play(__dir__, "kinney_context") do
    result = KinneyPointContextSpeak::KinneyContext.conduct
  end

  puts "context #{result.context_model} default #{result.context_default}"
  puts "global #{result.global_default}"
end
