# frozen_string_literal: true

# Error handling · 01 · Oranjestad aloe vat
#
# Teaches:
# - An unset OpenRouter key raises ConfigurationError before any HTTP call.
# - ConfigurationError inherits StandardError, not RubyLLM::Error.
# - The message names openrouter_api_key. There is no cassette.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module OranjestadAloeVat
  # The packing clerk at an Oranjestad aloe vat has no OpenRouter key.
  # Building a chat for the gel-cut brief fails on the desk, not on the wire.
  class MissingKey
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
        RubyLLM.chat(
          model: Multivitamin::Models::CHAT,
          provider: :openrouter,
          assume_model_exists: true
        )
      rescue RubyLLM::Error
        caught_as_provider_error = true
      rescue RubyLLM::ConfigurationError => error
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
        config.openrouter_api_key = nil
        config.openai_api_key = nil
        config.max_retries = 0
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "missing_key") do
    result = OranjestadAloeVat::MissingKey.conduct
  end

  puts result.error_class
  puts result.message
end
