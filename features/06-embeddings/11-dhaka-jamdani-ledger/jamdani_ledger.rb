# frozen_string_literal: true

# Embeddings · 11 · Dhaka jamdani ledger
#
# Teaches:
# - Store vectors with the model slug. Reload them from JSON and search
#   without embedding the corpus again.
# - A query must use the same slug. A different model is refused.

require "json"
require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module DhakaJamdaniLedger
  # The loft clerk in Narayanganj writes three weaving notes to a JSON
  # ledger, then searches it with a later question on the same model.
  class JamdaniLedger
    FOREIGN_MODEL = "text-embedding-3-large"

    Note = Struct.new(:title, :body, keyword_init: true)

    NOTES = [
      Note.new(
        title: "Warp knot on the jamdani",
        body: "The Narayanganj loft restung the warp of jamdani 17 with 84-thread unbleached cotton. Nabila seized the last eye at 16:40."
      ),
      Note.new(
        title: "Selvedge hangings on the sari",
        body: "Sari 4 needed forty new selvedge hangings after the Friday market. Thread is 15-count, green."
      ),
      Note.new(
        title: "Border splice on the wedding jamdani",
        body: "Wedding jamdani 2 has a chewed border just short of the right pallu. Splice with 36-thread before the next Dhanmondi showing."
      )
    ].freeze

    QUERY = "Which jamdani still needs a border splice before it shows in Dhanmondi?"

    Ranked = Struct.new(:title, :score, keyword_init: true)
    Result = Struct.new(
      :winner,
      :ranking,
      :stored_model,
      :stored_width,
      :reloaded,
      :foreign_error,
      :query_tokens,
      :cost,
      keyword_init: true
    )

    def self.conduct
      configure
      args = Multivitamin::Models.embed(provider: :openai)
      corpus = RubyLLM.embed(NOTES.map(&:body), **args)
      stored_model = corpus.model
      page = {
        "model" => stored_model,
        "dimensions" => corpus.vectors.fetch(0).length,
        "notes" => NOTES.each_with_index.map do |note, index|
          { "title" => note.title, "body" => note.body, "vector" => corpus.vectors.fetch(index) }
        end
      }
      reloaded = JSON.parse(JSON.generate(page))

      query = RubyLLM.embed(QUERY, **args)
      ranking = rank(query.vectors, reloaded.fetch("notes"))

      foreign_error = nil
      begin
        search_ledger(reloaded, QUERY, model: FOREIGN_MODEL, provider: :openai)
      rescue ArgumentError => error
        foreign_error = error.message
      end

      Result.new(
        winner: ranking.fetch(0).title,
        ranking: ranking,
        stored_model: reloaded.fetch("model"),
        stored_width: reloaded.fetch("dimensions"),
        reloaded: true,
        foreign_error: foreign_error,
        query_tokens: query.tokens.input,
        cost: corpus.cost.total + query.cost.total
      )
    end

    def self.search_ledger(ledger, question, model:, provider:)
      raise ArgumentError, "do not mix #{model} with a ledger stored as #{ledger.fetch('model')}" if model != ledger.fetch("model")

      query = RubyLLM.embed(question, model: model, provider: provider)
      rank(query.vectors, ledger.fetch("notes"))
    end

    def self.rank(query_vector, notes)
      notes.map do |note|
        Ranked.new(title: note.fetch("title"), score: cosine(query_vector, note.fetch("vector")))
      end.sort_by { |row| -row.score }
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
  Multivitamin::Cassettes.play(__dir__, "jamdani_ledger") do
    result = DhakaJamdaniLedger::JamdaniLedger.conduct
  end

  puts result.winner
  puts result.foreign_error
end
