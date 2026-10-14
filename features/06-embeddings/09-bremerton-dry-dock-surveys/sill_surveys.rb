# frozen_string_literal: true

# Embeddings · 09 · Bremerton dry dock surveys
#
# Teaches:
# - A survey sentence and its paraphrase outrank an unrelated crane note.
# - One batch holds the query, the paraphrase, and the crane.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module BremertonDryDockSurveys
  # The dockmaster at Puget Sound Naval Shipyard ranks a sill-water question
  # against a paraphrase of the sounding and against a crane repair.
  class SillSurveys
    QUERY = "How much water is over the dry dock sill this morning?"
    PARAPHRASE = "Sounding on the Bremerton dry dock sill is 14 ft above the blocks at 06:30."
    CRANE = "The west-wall crane needs a new snatch block before the next lift of the destroyer's screw."

    NOTES = [QUERY, PARAPHRASE, CRANE].freeze

    Result = Struct.new(
      :paraphrase_score,
      :crane_score,
      :model_id,
      :input_tokens,
      :cost,
      keyword_init: true
    )

    def self.conduct
      configure
      embedding = RubyLLM.embed(NOTES, **Multivitamin::Models.embed(provider: :openai))
      query, paraphrase, crane = embedding.vectors

      Result.new(
        paraphrase_score: cosine(query, paraphrase),
        crane_score: cosine(query, crane),
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
  Multivitamin::Cassettes.play(__dir__, "sill_surveys") do
    result = BremertonDryDockSurveys::SillSurveys.conduct
  end

  puts "sill #{result.paraphrase_score.round(4)} crane #{result.crane_score.round(4)}"
end
