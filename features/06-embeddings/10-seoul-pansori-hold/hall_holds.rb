# frozen_string_literal: true

# Embeddings · 10 · Seoul pansori hall hold
#
# Teaches:
# - A batch of hold notes is ranked against one query.
# - The highest score is named, not just numbered.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module SeoulPansoriHold
  # The house clerk at the National Gugak Center ranks this afternoon's
  # hold question against three posted notes and names the winner.
  class HallHolds
    QUERY = "Why is the afternoon pansori sitting holding in the hall?"

    Note = Struct.new(:title, :body, keyword_init: true)

    NOTES = [
      Note.new(
        title: "Cracked drumhead on the janggu",
        body: "The 19:45 sitting of Chunhyang is held in the hall. Drumhead split 28 mm from the rim, gaping 34. The west door is not clear."
      ),
      Note.new(
        title: "Tea urn in the foyer",
        body: "The foyer tea urn is down. Barley tea comes from the concession. The 19:45 still sits on time."
      ),
      Note.new(
        title: "Ticket window at the annex",
        body: "Annex ticket window is usable after 21:10 once the printer cools. The 19:45 cannot use that window even in a calm."
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
  Multivitamin::Cassettes.play(__dir__, "hall_holds") do
    result = SeoulPansoriHold::HallHolds.conduct
  end

  puts result.winner
  result.ranking.each { |row| puts "#{row.score.round(4)} #{row.title}" }
end
