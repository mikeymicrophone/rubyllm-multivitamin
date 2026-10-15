# frozen_string_literal: true

# Audio transcription · 03 · Sekiu Spanish hail
#
# Teaches:
# - language: sends an ISO 639-1 hint on the transcription request.
# - whisper-1 reports the language it heard on the Transcription.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module SekiuSpanishHail
  # The Sekiu float hails Neah Bay in Spanish so the Makah pilot boat
  # hears the request for Alden in the language the skipper used.
  class SpanishHail
    RECORDING = File.expand_path("sekiu-hail.mp3", __dir__)

    Result = Struct.new(:text, :language, :model, keyword_init: true)

    def self.conduct
      configure
      tape = RubyLLM.transcribe(
        RECORDING,
        **Multivitamin::Models.transcribe(model: Multivitamin::Models::OPENAI_TRANSCRIBE_WHISPER),
        language: "es"
      )

      Result.new(text: tape.text, language: tape.language, model: tape.model)
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
  Multivitamin::Cassettes.play(__dir__, "sekiu_hail") do
    result = SekiuSpanishHail::SpanishHail.conduct
  end

  puts result.language
  puts result.text
end
