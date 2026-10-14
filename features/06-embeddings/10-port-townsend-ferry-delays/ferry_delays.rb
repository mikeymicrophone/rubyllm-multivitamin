# frozen_string_literal: true

# Embeddings · 10 · Port Townsend ferry delays
#
# Teaches:
# - A batch of delay notes is ranked against one query.
# - The highest score is named, not just numbered.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PortTownsendFerryDelays
  # The slip clerk at Port Townsend ranks this morning's delay question
  # against three posted notes and names the winner.
  class FerryDelays
    QUERY = "Why is the Port Townsend–Coupeville sailing holding in the slip?"

    Note = Struct.new(:title, :body, keyword_init: true)

    NOTES = [
      Note.new(
        title: "Crosswind on the Port Townsend slip",
        body: "The 07:45 sailing to Coupeville is held in the slip. Crosswind 28 kn from the southwest, gusting 34. The wing wall is not clear."
      ),
      Note.new(
        title: "Galley cooler on Kennewick",
        body: "Kennewick's galley cooler is down. Box lunches come from the Port Townsend terminal. The 07:45 still sails on time."
      ),
      Note.new(
        title: "Tide window at the Coupeville apron",
        body: "Coupeville apron is usable after 09:10 once the tide lifts the landing. The 07:45 cannot make that apron even in a calm."
      )
    ].freeze

    Ranked = Struct.new(:title, :score, keyword_init: true)
    Result = Struct.new(:winner, :ranking, :model_id, :input_tokens, :cost, keyword_init: true)

    def self.conduct
      configure
      bodies = [QUERY, *NOTES.map(&:body)]
      embedding = RubyLLM.embed(bodies, **Multivitamin::Models.embed(provider: :openai))
      query_vector = embedding.vectors.fetch(0)
      ranking = NOTES.each_with_index.map do |note, index|
        Ranked.new(title: note.title, score: cosine(query_vector, embedding.vectors.fetch(index + 1)))
      end.sort_by { |row| -row.score }

      Result.new(
        winner: ranking.fetch(0).title,
        ranking: ranking,
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
  Multivitamin::Cassettes.play(__dir__, "ferry_delays") do
    result = PortTownsendFerryDelays::FerryDelays.conduct
  end

  puts result.winner
  result.ranking.each { |row| puts "#{row.score.round(4)} #{row.title}" }
end
