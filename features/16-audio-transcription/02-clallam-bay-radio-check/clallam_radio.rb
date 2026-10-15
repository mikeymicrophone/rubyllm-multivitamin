# frozen_string_literal: true

# Audio transcription · 02 · Clallam Bay radio check
#
# Teaches:
# - ctx.transcribe uses the context's default_transcription_model.
# - RubyLLM.config keeps the gem default when the context names whisper-1.
# - The context timeout stays off the global config.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module ClallamBayRadioCheck
  # Calder on the Clallam Bay watch desk files the radio-check tape through
  # a Strait context aimed at whisper-1, not the gem's gpt-transcribe default.
  class RadioCheck
    RECORDING = File.expand_path("clallam-bay-radio.mp3", __dir__)

    Result = Struct.new(
      :text,
      :model,
      :context_default,
      :global_default,
      :context_timeout,
      :global_timeout,
      keyword_init: true
    )

    def self.conduct
      configure
      bay = RubyLLM.context do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.default_transcription_model = Multivitamin::Models::OPENAI_TRANSCRIBE_WHISPER
        config.request_timeout = 90
      end

      tape = bay.transcribe(RECORDING)

      Result.new(
        text: tape.text,
        model: tape.model,
        context_default: bay.config.default_transcription_model,
        global_default: RubyLLM.config.default_transcription_model,
        context_timeout: bay.config.request_timeout,
        global_timeout: RubyLLM.config.request_timeout
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
  Multivitamin::Cassettes.play(__dir__, "clallam_radio") do
    result = ClallamBayRadioCheck::RadioCheck.conduct
  end

  puts "context #{result.context_default} global #{result.global_default}"
  puts result.text
end
