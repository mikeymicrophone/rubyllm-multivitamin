# frozen_string_literal: true

# Embeddings · 10 · Taipei nanguan hall hold
#
# Teaches:
# - A batch of hold notes is ranked against one query.
# - The highest score is named, not just numbered.
# - zip pairs notes with vectors; lazy scoring avoids index arithmetic.

require_relative "../../../support/runtime"
require_relative "../../../support/vectors"

module TaipeiNanguanHold
  # The house clerk at the Taipei nanguan hall ranks this afternoon's
  # hold question against three posted notes and names the winner.
  class HallHolds
    QUERY = "Why is the afternoon nanguan sitting holding in the hall?"

    Note = Data.define(:title, :body)

    NOTES = [
      Note.new(
        title: "Cracked soundboard on the pipa",
        body: "The 19:45 sitting of Chen San Wu Niang is held in the hall. Soundboard split 28 mm from the rim, gaping 34. The west door is not clear."
      ),
      Note.new(
        title: "Oolong urn in the foyer",
        body: "The foyer oolong urn is down. Barley tea comes from the concession. The 19:45 still sits on time."
      ),
      Note.new(
        title: "Ticket window at the annex",
        body: "Annex ticket window is usable after 21:10 once the printer cools. The 19:45 cannot use that window even in a calm."
      )
    ].freeze

    Ranked = Data.define(:title, :score)
    Result = Struct.new(:winner, :ranking, :model_id, :input_tokens, :cost, keyword_init: true)

    def self.conduct
      configure
      bodies = [QUERY, *NOTES.map(&:body)]
      embedding = RubyLLM.embed(bodies, **Multivitamin::Models.embed(provider: :openai))
      query_vector, *note_vectors = embedding.vectors
      ranking = NOTES.zip(note_vectors).lazy.map do |note, vector|
        Ranked.new(title: note.title, score: cosine(query_vector, vector))
      end.sort_by { |row| -row.score }

      Result.new(
        winner: ranking.fetch(0).title,
        ranking: ranking,
        model_id: embedding.model,
        input_tokens: embedding.tokens.input,
        cost: embedding.cost.total
      )
    end

    def self.cosine(left, right) = Multivitamin::Vectors.cosine(left, right)

    def self.configure = Multivitamin::Runtime.configure(provider: :openai)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "hall_holds") do
    TaipeiNanguanHold::HallHolds.conduct
  end

  puts result.winner
  result.ranking.each { |row| puts "#{row.score.round(4)} #{row.title}" }
end
