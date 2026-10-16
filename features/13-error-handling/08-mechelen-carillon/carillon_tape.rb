# frozen_string_literal: true

# Error handling · 08 · Mechelen carillon
#
# Teaches:
# - A WAV the model cannot format raises UnsupportedAttachmentError
#   before any HTTP call.
# - response and request_shape are both nil.
# - The message names the MIME type.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module MechelenCarillon
  # The practice loft at Mechelen's carillon school still files last
  # winter's rehearsal as a WAV. gpt-4.1-mini on the Responses API
  # will not take audio. The refusal never leaves the desk.
  class CarillonTape
    TAPE = File.expand_path("carillon-tape.wav", __dir__)

    TAPE_QUESTION = <<~TEXT.strip
      Mechelen carillon loft, Friday 16 October 2026.
      School notes: https://www.visitmechelen.be/en.
      Read the carillon tape and copy the hour-strike length.
    TEXT

    Result = Struct.new(
      :error,
      :message,
      :response,
      :shape,
      :mime,
      :is_llm_error,
      keyword_init: true
    )

    def self.conduct
      configure

      tape = RubyLLM::Attachment.new(TAPE)
      error = nil
      begin
        chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
        chat.ask(TAPE_QUESTION, with: TAPE)
      rescue RubyLLM::Error => raised
        error = raised
      end

      Result.new(
        error: error,
        message: error&.message,
        response: error&.response,
        shape: error&.request_shape,
        mime: tape.mime_type,
        is_llm_error: error.is_a?(RubyLLM::Error)
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
  Multivitamin::Cassettes.play(__dir__, "carillon_tape") do
    result = MechelenCarillon::CarillonTape.conduct
  end

  puts result.error.class
  puts result.message
end
