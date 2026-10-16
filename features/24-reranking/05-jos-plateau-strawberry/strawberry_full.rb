# frozen_string_literal: true

# Reranking · 05 · Jos plateau strawberry
#
# Teaches:
# - A second Voyage slug, rerank-2.5, is not the lite default.
# - The request body names the full slug.
# - The ripe-bed card still lands first.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module JosPlateauStrawberry
  class StrawberryFull
    QUERY = "Which bed is the ripe Jos plateau strawberry for the morning crate?"

    BEDS = [
      "Bed 1, green fruit, hold until Thursday.",
      "Bed 4, ripe Jos plateau strawberry for the morning crate, 18 kilos.",
      "Bed 7, runner nursery, not fruit.",
      "Bed 9, mulch only."
    ].freeze

    Result = Struct.new(:index, :document, :model, :requested, keyword_init: true)

    def self.conduct
      configure

      ranked = RubyLLM.rerank(
        QUERY,
        BEDS,
        **Multivitamin::Models.rerank(model: Multivitamin::Models::OPENROUTER_RERANK_FULL)
      )
      first = ranked.results.first

      Result.new(
        index: first.index,
        document: first.document,
        model: ranked.model,
        requested: Multivitamin::Models::OPENROUTER_RERANK_FULL
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
  Multivitamin::Cassettes.play(__dir__, "strawberry_full") do
    result = JosPlateauStrawberry::StrawberryFull.conduct
  end

  puts "index=#{result.index} model=#{result.model}"
  puts result.document
end
