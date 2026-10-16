# frozen_string_literal: true

# Moderation · 08 · Alice Springs didgeridoo
#
# Teaches:
# - A WAV the moderation protocol cannot format raises
#   UnsupportedAttachmentError before any HTTP call.
# - There is no cassette file.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AliceSpringsDidgeridoo
  # The rehearsal loft in Alice Springs still files last winter's
  # didgeridoo take as a WAV. Omni-moderation will not take audio. The
  # refusal never leaves the desk.
  class DidgeridooTape
    TAPE = File.expand_path("rehearsal-tape.wav", __dir__)

    Result = Struct.new(:error, :mime, :is_llm_error, keyword_init: true)

    def self.conduct
      configure

      tape = RubyLLM::Attachment.new(TAPE)
      error = nil
      begin
        RubyLLM.moderate(with: TAPE, **Multivitamin::Models.moderation)
      rescue RubyLLM::Error => raised
        error = raised
      end

      Result.new(
        error: error,
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
  Multivitamin::Cassettes.play(__dir__, "didgeridoo_tape") do
    result = AliceSpringsDidgeridoo::DidgeridooTape.conduct
  end

  puts result.error.class
  puts result.error.message
end
