# frozen_string_literal: true

# Reranking · 10 · Nadi ginger shed
#
# Teaches:
# - model: is a required keyword. Omitting it raises ArgumentError
#   before any HTTP call.
# - There is no cassette file.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module NadiGingerShed
  class GingerMissing
    QUERY = "Which crate is the Nadi ginger for the morning weigh?"
    CRATES = ["Crate 2, young ginger, 12 kilos.", "Crate 5, turmeric, not ginger."].freeze

    Result = Struct.new(:error, :keyword, keyword_init: true)

    def self.conduct
      configure

      error = nil
      begin
        RubyLLM.rerank(QUERY, CRATES)
      rescue ArgumentError => raised
        error = raised
      end

      Result.new(error: error, keyword: "model")
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
  Multivitamin::Cassettes.play(__dir__, "ginger_missing") do
    result = NadiGingerShed::GingerMissing.conduct
  end

  puts result.error.class
  puts result.error.message
end
