# frozen_string_literal: true

# Reranking · 08 · Dunedin tweed mill
#
# Teaches:
# - Embed the query first, then rerank the candidate notes.
# - This catalog has no neighbor gem. The mill still retrieves by hand.
# - The cassette is one embeddings POST and one rerank POST.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module DunedinTweedMill
  class TweedMill
    QUERY = "Which loom is the Harris-weight tweed for the school kilts?"

    LOOMS = [
      "Loom 1, Shetland lace, not tweed.",
      "Loom 3, Harris-weight tweed for the school kilts, 40 metres, Dunedin.",
      "Loom 5, blanket wool, too heavy.",
      "Loom 8, sample wrap, not a kilt length."
    ].freeze

    Result = Struct.new(:index, :document, :vector_size, :model, keyword_init: true)

    def self.conduct
      configure

      embedding = RubyLLM.embed(QUERY, **Multivitamin::Models.embed(provider: :openai))
      ranked = RubyLLM.rerank(QUERY, LOOMS, **Multivitamin::Models.rerank)
      first = ranked.results.first

      Result.new(
        index: first.index,
        document: first.document,
        vector_size: Array(embedding.vectors).length,
        model: ranked.model
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        Multivitamin::Models.configure(config, provider: :openrouter)
        config.max_retries = 0
        config.request_timeout = 90
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "tweed_mill") do
    result = DunedinTweedMill::TweedMill.conduct
  end

  puts "index=#{result.index} vectors=#{result.vector_size}"
  puts result.document
end
