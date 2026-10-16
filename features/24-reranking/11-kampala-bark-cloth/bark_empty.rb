# frozen_string_literal: true

# Reranking · 11 · Kampala bark cloth
#
# Teaches:
# - An empty document list still has to go through the provider.
# - Voyage answers with an error or an empty ranking. The desk records
#   whichever shape comes back.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module KampalaBarkCloth
  class BarkEmpty
    QUERY = "Which bark-cloth panel is the morning dye for the Kasubi cloak?"

    Result = Struct.new(:error, :count, :empty, keyword_init: true)

    def self.conduct
      configure

      error = nil
      count = nil
      begin
        ranked = RubyLLM.rerank(QUERY, [], **Multivitamin::Models.rerank)
        count = ranked.results.length
      rescue RubyLLM::Error, ArgumentError => raised
        error = raised
      end

      Result.new(error: error, count: count, empty: true)
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
  Multivitamin::Cassettes.play(__dir__, "bark_empty") do
    result = KampalaBarkCloth::BarkEmpty.conduct
  end

  puts "error=#{result.error&.class} count=#{result.count.inspect}"
  puts result.error&.message
end
