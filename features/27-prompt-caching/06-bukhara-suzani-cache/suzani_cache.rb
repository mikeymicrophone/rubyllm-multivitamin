# frozen_string_literal: true

# Prompt caching · 06 · Bukhara suzani cache
#
# Teaches:
# - RubyLLM.cache creates a Gemini/Vertex CachedContent resource.
# - OpenAI answers RubyLLM::Error before any HTTP call.
# - There is no cassette file. cache.renew is the same family.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module BukharaSuzaniCache
  class SuzaniCache
    POLICY = (1..12).map { |n|
      "Bukhara suzani standing order #{n}: hanging #{n} is lot BKH-2026-1016-S#{n}, " \
        "Dilshod stitches the border at the Registan stall."
    }.join(" ")

    Result = Struct.new(:error, :message, keyword_init: true)

    def self.conduct
      configure

      error = nil
      begin
        RubyLLM.cache(
          POLICY,
          model: Multivitamin::Models::OPENAI_CHAT,
          provider: :openai,
          ttl: 3600
        )
      rescue RubyLLM::Error => raised
        error = raised
      end

      Result.new(error: error, message: error&.message)
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
  Multivitamin::Cassettes.play(__dir__, "suzani_cache") do
    result = BukharaSuzaniCache::SuzaniCache.conduct
  end

  puts result.error.class
  puts result.message
end
