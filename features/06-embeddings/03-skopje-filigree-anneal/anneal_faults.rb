# frozen_string_literal: true

# Embeddings · 03 · Skopje filigree anneal faults
#
# Teaches:
# - Cosine similarity ranks two torch faults above a bakery log.
# - The three notes ride in one batch so the cassette is one round-trip.
# - A lexical refinement adds cosine_sim only inside this scenario.

require_relative "../../../support/runtime"
require_relative "../../../support/vectors"

module SkopjeFiligreeAnneal
  module AnnealingVectors
    refine Array do
      def cosine_sim(other) = Multivitamin::Vectors.cosine(self, other)
    end
  end

  using AnnealingVectors

  # The silversmith in the Old Bazaar compares a new annealing complaint
  # to last week's gas-pressure note and to an unrelated burek bake.
  class AnnealFaults
    TORCH_TWIN = "Annealing torch pressure dropped to 18 psi during the 2-second heat."
    TORCH_ECHO = "The annealing torch lost gas pressure on the two-second heat."
    OVEN_LOG = "Burek oven 3 at the Old Bazaar bakery held 242 C for the morning cheese bake."

    NOTES = [TORCH_TWIN, TORCH_ECHO, OVEN_LOG].freeze

    Result = Struct.new(
      :twin_score,
      :cook_score,
      :vectors,
      :model_id,
      :input_tokens,
      :cost,
      keyword_init: true
    )

    def self.conduct
      configure
      embedding = RubyLLM.embed(NOTES, **Multivitamin::Models.embed(provider: :openai))
      twin, echo, cook = embedding.vectors

      Result.new(
        twin_score: twin.cosine_sim(echo),
        cook_score: twin.cosine_sim(cook),
        vectors: embedding.vectors,
        model_id: embedding.model,
        input_tokens: embedding.tokens.input,
        cost: embedding.cost.total
      )
    end

    def self.configure = Multivitamin::Runtime.configure(provider: :openai)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "anneal_faults") do
    SkopjeFiligreeAnneal::AnnealFaults.conduct
  end

  puts "twin #{result.twin_score.round(4)} cook #{result.cook_score.round(4)}"
end
