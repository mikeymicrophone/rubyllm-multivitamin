# frozen_string_literal: true

# Reranking · 06 · Cuenca toquilla hat
#
# Teaches:
# - A Spanish query still ranks mixed Spanish and English cards.
# - Vertex semantic-ranker needs GCP this catalog does not have.
# - The bloque fino card still lands first.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module CuencaToquillaHat
  class ToquillaHat
    QUERY = "¿Cuál bloque es el fino de toquilla para el sombrero de gala?"

    BLOCKS = [
      "Block A, coarse toquilla, market hats only.",
      "Block C, bloque fino de toquilla para el sombrero de gala, 40 copas, Cuenca.",
      "Block D, dyed brim offcuts, not gala.",
      "English card: Panama-style brim mill, not Cuenca toquilla."
    ].freeze

    Result = Struct.new(:index, :document, :score, keyword_init: true)

    def self.conduct
      configure

      ranked = RubyLLM.rerank(QUERY, BLOCKS, **Multivitamin::Models.rerank)
      first = ranked.results.first

      Result.new(
        index: first.index,
        document: first.document,
        score: first.score
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
  Multivitamin::Cassettes.play(__dir__, "toquilla_hat") do
    result = CuencaToquillaHat::ToquillaHat.conduct
  end

  puts "index=#{result.index}"
  puts result.document
end
