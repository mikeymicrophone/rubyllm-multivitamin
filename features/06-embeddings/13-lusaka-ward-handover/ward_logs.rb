# frozen_string_literal: true

# Embeddings · 13 · Lusaka night-ward handover
#
# Teaches:
# - A small corpus of titled ward logs is searched with one question.
# - Ranked titles come from cosine on stored vectors.
# - Replay uses the cassette. The live model is not asked again.

require_relative "../../../support/runtime"
require_relative "../../../support/vectors"

module LusakaWardHandover
  # The overnight clerk at University Teaching Hospital ranks a paediatric
  # question against four titled logs from the night's desks.
  class WardLogs
    QUERY = "When can nurse Chanda leave the paediatric bay?"

    Log = Struct.new(:title, :body, keyword_init: true)

    LOGS = [
      Log.new(
        title: "Paediatric vitals board",
        body: "University Teaching Hospital, Wednesday 14 October 2026. Low fever 06:42 at 37.4 C. High fever 12:18 at 38.1 C. Chanda clears the paediatric bay at 10:46. Pharmacy can use the trolley at 08:57."
      ),
      Log.new(
        title: "Main autoclave card",
        body: "Main autoclave, 2-second vent, 18-second hold, jacket 42 psi, next relief 08:00."
      ),
      Log.new(
        title: "Kitchen nshima pot",
        body: "Kitchen kettle 2, pot 3 of nshima, lot UTH-314, 96 C hold, clerk Mutale, posted at 11:18."
      ),
      Log.new(
        title: "Pharmacy window B4",
        body: "Pharmacy window B4 takes the evening refill at 14:10. Do not park Chanda's trolley outside B4. Queue 1.2 from the south ward."
      )
    ].freeze

    Ranked = Struct.new(:title, :score, keyword_init: true)
    Result = Struct.new(:winner, :ranking, :model_id, :input_tokens, :cost, :roles, keyword_init: true)

    def self.conduct
      configure
      bodies = [QUERY, *LOGS.map(&:body)]
      embedding = RubyLLM.embed(bodies, **Multivitamin::Models.embed(provider: :openai))
      query_vector = embedding.vectors.fetch(0)
      ranking = LOGS.each_with_index.map do |log, index|
        Ranked.new(title: log.title, score: cosine(query_vector, embedding.vectors.fetch(index + 1)))
      end.sort_by { |row| -row.score }

      Result.new(
        winner: ranking.fetch(0).title,
        ranking: ranking,
        model_id: embedding.model,
        input_tokens: embedding.tokens.input,
        cost: embedding.cost.total,
        roles: %i[query corpus]
      )
    end

    def self.cosine(left, right) = Multivitamin::Vectors.cosine(left, right)

    def self.configure = Multivitamin::Runtime.configure(provider: :openai)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "ward_logs") do
    LusakaWardHandover::WardLogs.conduct
  end

  puts result.winner
  result.ranking.each { |row| puts "#{row.score.round(4)} #{row.title}" }
end
