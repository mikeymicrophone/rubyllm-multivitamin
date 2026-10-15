# frozen_string_literal: true

# Audio transcription · 01 · Tatoosh foghorn tape
#
# Teaches:
# - RubyLLM.transcribe turns a recording into a RubyLLM::Transcription.
# - model: and provider: select gpt-transcribe on OpenAI.
# - text and model are read off that object.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module TatooshFoghornTape
  # The foghorn tender at Tatoosh Island files the morning visibility tape
  # before the watch at Cape Flattery copies it into the horn log.
  class FoghornTape
    RECORDING = File.expand_path("tatoosh-foghorn.mp3", __dir__)

    Result = Struct.new(:text, :model, :klass, keyword_init: true)

    def self.conduct
      configure
      tape = RubyLLM.transcribe(RECORDING, **Multivitamin::Models.transcribe)

      Result.new(
        text: tape.text,
        model: tape.model,
        klass: tape.class.name
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
  Multivitamin::Cassettes.play(__dir__, "tatoosh_foghorn") do
    result = TatooshFoghornTape::FoghornTape.conduct
  end

  puts result.model
  puts result.text
end
