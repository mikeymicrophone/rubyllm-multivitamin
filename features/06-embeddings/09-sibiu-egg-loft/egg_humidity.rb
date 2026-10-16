# frozen_string_literal: true

# Embeddings · 09 · Sibiu painted-egg loft
#
# Teaches:
# - A loft sentence and its paraphrase outrank an unrelated eave note.
# - One batch holds the query, the paraphrase, and the eave.
# - A curried method supplies the query vector to both cosine reductions.

require_relative "../../../support/runtime"
require_relative "../../../support/vectors"

module SibiuEggLoft
  # The workshop keeper in the Upper Town ranks a humidity question
  # against a paraphrase of the morning hygrometer and against an eave leak.
  class EggHumidity
    QUERY = "How dry is the painted-egg loft this morning?"
    PARAPHRASE = "Hygrometer on the Sibiu egg-painting loft is 14 percent above the chalk line at 06:30."
    EAVE = "The west-wall eave needs a new flashing before the next storm hits the workshop roof."

    NOTES = [QUERY, PARAPHRASE, EAVE].freeze

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
      score_against_query = Multivitamin::Vectors.method(:cosine).curry[query]
      paraphrase_score, eave_score = [paraphrase, crane].map(&score_against_query)

      Result.new(
        paraphrase_score: paraphrase_score,
        crane_score: eave_score,
        model_id: embedding.model,
        input_tokens: embedding.tokens.input,
        cost: embedding.cost.total
      )
    end

    def self.configure = Multivitamin::Runtime.configure(provider: :openai)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "egg_humidity") do
    SibiuEggLoft::EggHumidity.conduct
  end

  puts "loft #{result.paraphrase_score.round(4)} eave #{result.crane_score.round(4)}"
end
