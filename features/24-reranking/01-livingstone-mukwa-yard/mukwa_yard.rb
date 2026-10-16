# frozen_string_literal: true

# Reranking · 01 · Livingstone mukwa yard
#
# Teaches:
# - RubyLLM.rerank orders documents by relevance to a query.
# - results.first has index, document, and score.
# - model: is required. There is no default rerank model.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module LivingstoneMukwaYard
  # The timber clerk in Livingstone asks which stack is the mukwa for
  # the school desks. The pine and teak cards sit first. Voyage puts
  # the mukwa card on top.
  class MukwaYard
    QUERY = "Which stack is the mukwa for the school desks?"

    DOCUMENTS = [
      "Stack A, pine battens, 40 lengths, for the market stalls.",
      "Stack B, teak offcuts, 12 boards, holding for the river workshop.",
      "Stack C, mukwa for the school desks, 28 boards, yard 2 in Livingstone.",
      "Stack D, mopane firewood, not for joinery."
    ].freeze

    Result = Struct.new(:index, :document, :score, :count, :model, keyword_init: true)

    def self.conduct
      configure

      ranked = RubyLLM.rerank(QUERY, DOCUMENTS, **Multivitamin::Models.rerank)
      first = ranked.results.first

      Result.new(
        index: first.index,
        document: first.document,
        score: first.score,
        count: ranked.results.length,
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
  Multivitamin::Cassettes.play(__dir__, "mukwa_yard") do
    result = LivingstoneMukwaYard::MukwaYard.conduct
  end

  puts "index=#{result.index} score=#{result.score}"
  puts result.document
end
