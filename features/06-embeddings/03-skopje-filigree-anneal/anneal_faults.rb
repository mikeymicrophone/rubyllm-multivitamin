# frozen_string_literal: true

# Embeddings · 03 · Skopje filigree anneal faults
#
# Teaches:
# - Cosine similarity ranks two torch faults above a bakery log.
# - The three notes ride in one batch so the cassette is one round-trip.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module SkopjeFiligreeAnneal
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
        twin_score: cosine(twin, echo),
        cook_score: cosine(twin, cook),
        vectors: embedding.vectors,
        model_id: embedding.model,
        input_tokens: embedding.tokens.input,
        cost: embedding.cost.total
      )
    end

    def self.cosine(left, right)
      dot = 0.0
      na = 0.0
      nb = 0.0
      left.each_index do |index|
        dot += left[index] * right[index]
        na += left[index] * left[index]
        nb += right[index] * right[index]
      end
      dot / (Math.sqrt(na) * Math.sqrt(nb))
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
  Multivitamin::Cassettes.play(__dir__, "anneal_faults") do
    result = SkopjeFiligreeAnneal::AnnealFaults.conduct
  end

  puts "twin #{result.twin_score.round(4)} cook #{result.cook_score.round(4)}"
end
