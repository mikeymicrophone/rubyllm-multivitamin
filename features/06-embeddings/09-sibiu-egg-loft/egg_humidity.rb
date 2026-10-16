# frozen_string_literal: true

# Embeddings · 09 · Sibiu painted-egg loft
#
# Teaches:
# - A loft sentence and its paraphrase outrank an unrelated eave note.
# - One batch holds the query, the paraphrase, and the eave.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

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
  Multivitamin::Cassettes.play(__dir__, "egg_humidity") do
    result = SibiuEggLoft::EggHumidity.conduct
  end

  puts "loft #{result.paraphrase_score.round(4)} eave #{result.crane_score.round(4)}"
end
