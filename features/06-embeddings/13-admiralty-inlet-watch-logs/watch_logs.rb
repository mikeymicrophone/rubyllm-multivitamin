# frozen_string_literal: true

# Embeddings · 13 · Admiralty Inlet watch logs
#
# Teaches:
# - A small corpus of titled station logs is searched with one question.
# - Ranked titles come from cosine on stored vectors.
# - Replay uses the cassette. The live model is not asked again.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AdmiraltyInletWatchLogs
  # The overnight clerk at Admiralty Inlet ranks a kelp-ledge question
  # against four titled logs from the night's stations.
  class WatchLogs
    QUERY = "When can the foghorn tender Alden leave the Point Wilson float?"

    Log = Struct.new(:title, :body, keyword_init: true)

    LOGS = [
      Log.new(
        title: "Point Wilson tide board",
        body: "Point Wilson, Wednesday 14 October 2026. Low water 06:42 at 0.4 ft. High water 12:18 at 8.1 ft. Alden clears the kelp ledge at 10:46. Retort can use the float at 08:57."
      ),
      Log.new(
        title: "Cape Disappointment horn card",
        body: "Cape Disappointment foghorn, 2-second blast, 18-second silence, compressor oil 42 psi, next relief 08:00."
      ),
      Log.new(
        title: "Anacortes morning cook",
        body: "Anacortes cannery retort 2, basket 3 of sockeye, lot ANC-314, 242 F hold, clerk Maren, cook posted at 11:18."
      ),
      Log.new(
        title: "Friday Harbor slip B4",
        body: "Friday Harbor packet San Juan Islander takes slip B4 at 14:10. Do not raft Alden outside B4. Flood 1.2 kn from the south."
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
  Multivitamin::Cassettes.play(__dir__, "watch_logs") do
    result = AdmiraltyInletWatchLogs::WatchLogs.conduct
  end

  puts result.winner
  result.ranking.each { |row| puts "#{row.score.round(4)} #{row.title}" }
end
