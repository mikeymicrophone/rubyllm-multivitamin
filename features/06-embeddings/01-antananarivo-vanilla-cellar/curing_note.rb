# frozen_string_literal: true

# Embeddings · 01 · Antananarivo vanilla cellar
#
# Teaches:
# - RubyLLM.embed turns one string into a vector on embedding.vectors.
# - A single string comes back as a flat Array of Float, not an array of vectors.
# - model, tokens.input, cost.total, and sparse_vectors are read off that result.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AntananarivoVanillaCellar
  # The Razafy household in Isotry embeds one posted curing note so later
  # harvests can search the desk without rereading the chalk.
  class CuringNote
    BOARD_NOTE = <<~TEXT.strip
      Antananarivo vanilla cellar, Wednesday 14 October 2026.
      Isotry curing shed, crate 4 of Bourbon beans.
      Noro opens crate 4 at 06:42, 0.4 m below the lid.
      Hery can take the first braid at 08:57.
      Lalao clears the sweating ledge at 10:46.
    TEXT

    Result = Struct.new(
      :vectors,
      :model_id,
      :sparse_vectors,
      :input_tokens,
      :cost,
      keyword_init: true
    )

    def self.conduct
      configure
      embedding = RubyLLM.embed(BOARD_NOTE, **embed_args)

      Result.new(
        vectors: embedding.vectors,
        model_id: embedding.model,
        sparse_vectors: embedding.sparse_vectors,
        input_tokens: embedding.tokens.input,
        cost: embedding.cost.total
      )
    end

    def self.embed_args
      Multivitamin::Models.embed(provider: :openai)
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
  Multivitamin::Cassettes.play(__dir__, "curing_note") do
    result = AntananarivoVanillaCellar::CuringNote.conduct
  end

  puts "#{result.model_id} #{result.vectors.length} dimensions"
end
