# frozen_string_literal: true

# Embeddings · 02 · Mandalay lacquer drawers
#
# Teaches:
# - An array of strings is one API call and one Embedding.
# - vectors.length matches the number of notes.
# - Each inner vector is the same length.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module MandalayLacquerDrawers
  # The atelier clerk on 26th Street embeds four drawer notes together so a
  # later search can rank a cracked cup against a seized betel box.
  class LacquerDrawers
    NOTES = [
      "Drawer A, bamboo cup blank, catalog NP-4, cracked, do not issue.",
      "Drawer B, spare gold-leaf book, catalog NB-17, haze on the inner face.",
      "Drawer C, six horsehair brushes, catalog LC-6, two chipped at the ferrule.",
      "Drawer D, betel box latch, catalog CW-2, seized and waiting on a pin."
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
  Multivitamin::Cassettes.play(__dir__, "lacquer_drawers") do
    result = MandalayLacquerDrawers::LacquerDrawers.conduct
  end

  puts "#{result.vectors.length} cabinet notes, #{result.vectors.fetch(0).length} dimensions"
end
