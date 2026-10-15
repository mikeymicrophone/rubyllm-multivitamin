# frozen_string_literal: true

# Text to speech · 12 · Middle Point refused format
#
# Teaches:
# - format: "aiff" raises RubyLLM::BadRequestError on tts-1.
# - The message is Invalid response_format.
# - The cassette is the 400. There is no audio payload to shrink.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module MiddlePointRefusedFormat
  # The inlet watch at Middle Point asked for an AIFF hail. The model
  # refuses that container.
  class MiddleRefusal
    HAIL = "Middle Point. Aiff refused."

    Result = Struct.new(:error_class, :message, keyword_init: true)

    def self.conduct
      configure
      RubyLLM.speak(HAIL, **Multivitamin::Models.speech(format: "aiff"))
      Result.new(error_class: nil, message: nil)
    rescue RubyLLM::BadRequestError => error
      Result.new(error_class: error.class, message: error.message)
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
  Multivitamin::Cassettes.play(__dir__, "middle_refusal") do
    result = MiddlePointRefusedFormat::MiddleRefusal.conduct
  end

  puts result.error_class
  puts result.message
end
