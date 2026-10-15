# frozen_string_literal: true

# Embeddings · 02 · Chiang Mai sa-paper umbrella drawers
#
# Teaches:
# - An array of strings is one API call and one Embedding.
# - vectors.length matches the number of notes.
# - Each inner vector is the same length.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module ChiangMaiUmbrellaDrawers
  # The atelier clerk at Bo Sang embeds four drawer notes together so a
  # later search can rank cracked bamboo against seized gold leaf.
  class UmbrellaDrawers
    NOTES = [
      "Drawer A, bamboo rib bundle, catalog NP-4, cracked, do not issue.",
      "Drawer B, spare sa paper, catalog NB-17, haze on the inner face.",
      "Drawer C, six lacquer brushes, catalog LC-6, two chipped at the ferrule.",
      "Drawer D, gold-leaf book, catalog CW-2, seized and waiting on a pin."
    ].freeze

    Result = Struct.new(:vectors, :model_id, :input_tokens, :cost, keyword_init: true)

    def self.conduct
      configure
      embedding = RubyLLM.embed(NOTES, **Multivitamin::Models.embed(provider: :openai))

      Result.new(
        vectors: embedding.vectors,
        model_id: embedding.model,
        input_tokens: embedding.tokens.input,
        cost: embedding.cost.total
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 120
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "umbrella_drawers") do
    result = ChiangMaiUmbrellaDrawers::UmbrellaDrawers.conduct
  end

  puts "#{result.vectors.length} cabinet notes, #{result.vectors.fetch(0).length} dimensions"
end
