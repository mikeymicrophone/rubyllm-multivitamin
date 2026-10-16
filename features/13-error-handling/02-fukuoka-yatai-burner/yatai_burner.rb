# frozen_string_literal: true

# Error handling · 02 · Fukuoka yatai burner
#
# Teaches:
# - find raises ModelNotFoundError for an id the registry does not carry.
# - The message names refresh. This scenario does not call refresh.
# - ModelNotFoundError inherits StandardError, not RubyLLM::Error.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"

module FukuokaYataiBurner
  # The stall cook on Nakasu looks up a yatai-burner model the current
  # list does not carry. The miss is an error. Pulling a new list would
  # not recover a number that was never assigned.
  class YataiBurner
    DROPPED = "fukuoka-yatai-burner-unlisted"

    Result = Struct.new(
      :error_class,
      :message,
      :superclass,
      :caught_as_provider_error,
      keyword_init: true
    )

    def self.conduct
      configure

      error_class = nil
      message = nil
      superclass = nil
      caught_as_provider_error = false
      begin
        RubyLLM.models.find(DROPPED)
      rescue RubyLLM::Error
        caught_as_provider_error = true
      rescue RubyLLM::ModelNotFoundError => error
        error_class = error.class.name
        message = error.message
        superclass = error.class.superclass.name
      end

      Result.new(
        error_class: error_class,
        message: message,
        superclass: superclass,
        caught_as_provider_error: caught_as_provider_error
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        config.max_retries = 0
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "yatai_burner") do
    result = FukuokaYataiBurner::YataiBurner.conduct
  end

  puts result.error_class
  puts result.message
end
