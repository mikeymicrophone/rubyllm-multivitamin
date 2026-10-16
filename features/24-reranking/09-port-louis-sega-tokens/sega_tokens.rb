# frozen_string_literal: true

# Reranking · 09 · Port Louis sega tokens
#
# Teaches:
# - rerank.tokens.input and rerank.cost.total sit on the same ledger as chat.
# - Voyage on OpenRouter reports usage when the body carries it.
# - A nil token count is still a legal provider answer.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PortLouisSegaTokens
  class SegaTokens
    QUERY = "Which set is the Saturday sega at the Port Louis market?"

    SETS = [
      "Sunday séga at Flic-en-Flac, beach stage.",
      "Saturday sega at the Port Louis market, 18:00, ravanne and triangle.",
      "Monday rehearsal, no public set.",
      "Hotel lobby piano, not sega."
    ].freeze

    Result = Struct.new(:index, :input_tokens, :cost, :model, keyword_init: true)

    def self.conduct
      configure

      ranked = RubyLLM.rerank(QUERY, SETS, **Multivitamin::Models.rerank)

      Result.new(
        index: ranked.results.first.index,
        input_tokens: ranked.tokens.input,
        cost: ranked.cost.total,
        model: ranked.model
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
  Multivitamin::Cassettes.play(__dir__, "sega_tokens") do
    result = PortLouisSegaTokens::SegaTokens.conduct
  end

  puts "index=#{result.index} tokens=#{result.input_tokens.inspect} cost=#{result.cost.inspect}"
end
