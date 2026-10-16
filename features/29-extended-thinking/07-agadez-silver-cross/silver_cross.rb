# frozen_string_literal: true

# Extended thinking · 07 · Agadez silver cross
#
# Teaches:
# - with_thinking(false) stores a disable intent. chat.thinking resolves
#   it and raises ArgumentError: gpt-4.1-mini has no off control.
# - There is no cassette file.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AgadezSilverCross
  class SilverCross
    Result = Struct.new(:error, :message, keyword_init: true)

    def self.conduct
      configure
      error = nil
      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      begin
        chat.with_thinking(false)
        chat.thinking
      rescue ArgumentError => raised
        error = raised
      end
      Result.new(error: error, message: error&.message)
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 180
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "silver_cross") do
    result = AgadezSilverCross::SilverCross.conduct
  end

  puts result.error.class
  puts result.message
end
