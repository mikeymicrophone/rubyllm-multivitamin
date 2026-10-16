# frozen_string_literal: true

# Error handling · 04 · Rotterdam gouda warehouse
#
# Teaches:
# - HTTP 429 becomes RateLimitError. max_retries is 0 so the cassette is
#   one POST.
# - Error#response holds the provider body. OpenRouter's free-model 429
#   names the upstream pool.
# - ContextLengthExceededError is not this class, even on a 400.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module RotterdamGoudaWarehouse
  # The ripening clerk at a Rotterdam gouda warehouse reads the free
  # OpenRouter humidity model. The shared free pool answers 429. Faraday
  # does not retry: max_retries is 0.
  class RateLimit
    SLUG = "poolside/laguna-s-2.1:free"

    INSTRUCTIONS = <<~TEXT.strip
      You are the ripening clerk at a Rotterdam gouda warehouse.
      Answer in one short sentence.
      Use only the humidity card in the question.
      Name 0.4 and the fans.
    TEXT

    CARD_QUESTION = <<~TEXT.strip
      Humidity card posted at the Rotterdam gouda warehouse, Friday 16 October 2026.
      City notes: https://www.rotterdam.info/en/.
      Humidity 0.4 percent above the 88 percent target.
      Aisle fans running on the west rack of 14-month wheels.
      What is the humidity drift, and are the fans running?
    TEXT

    Result = Struct.new(:error, :status, :body, :slug, keyword_init: true)

    def self.conduct
      configure

      chat = RubyLLM.chat(
        model: SLUG,
        provider: :openrouter,
        assume_model_exists: true
      )
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.with_max_output_tokens(64)

      error = nil
      begin
        chat.ask(CARD_QUESTION)
      rescue RubyLLM::Error => raised
        error = raised
      end

      Result.new(
        error: error,
        status: error&.response&.status,
        body: error&.response&.body.to_s,
        slug: SLUG
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openrouter)
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
  Multivitamin::Cassettes.play(__dir__, "rate_limit") do
    result = RotterdamGoudaWarehouse::RateLimit.conduct
  end

  puts "#{result.error.class} #{result.status}"
  puts result.error.message
end
