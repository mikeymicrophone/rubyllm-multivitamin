# frozen_string_literal: true

# Embeddings · 12 · Beirut galley proofs
#
# Teaches:
# - Near-duplicate galley corrections cluster together.
# - A catering card that borrows the same tokens (DH, 18465, 300, northwest)
#   stays out of that cluster and ranks below a true match.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module BeirutGalleyProofs
  # The compositor at a Hamra press clusters two blurbs about folio DH
  # moving 300 lines, and keeps a zaatar card that reused those tokens.
  class GalleyProofs
    CLUSTER_FLOOR = 0.8
    QUERY = "Where did folio DH move in galley 18465?"

    Note = Struct.new(:title, :body, keyword_init: true)

    NOTES = [
      Note.new(
        title: "DH moved northwest",
        body: "Galley 18465. Folio DH is moved 300 lines northwest of the printed mark. Do not use the old mark for a lockup."
      ),
      Note.new(
        title: "DH shifted 300 lines",
        body: "Galley 18465 correction: folio DH moved 300 lines northwest. The printed mark is stale. Do not lock on it."
      ),
      Note.new(
        title: "Catering card DH-18465",
        body: "Press-room catering card DH-18465: tray 3 held 300 seconds after the oven latch. Do not use the old mark on the zaatar bake. Northwest kettle is idle."
      )
    ].freeze

    Cluster = Struct.new(:title, :members, keyword_init: true)
    Ranked = Struct.new(:title, :score, keyword_init: true)
    Result = Struct.new(
      :clusters,
      :duplicate_titles,
      :cook_cluster,
      :winner,
      :cook_score,
      :model_id,
      :input_tokens,
      :cost,
      keyword_init: true
    )

    def self.conduct
      configure
      bodies = [QUERY, *NOTES.map(&:body)]
      embedding = RubyLLM.embed(bodies, **Multivitamin::Models.embed(provider: :openai))
      query_vector = embedding.vectors.fetch(0)
      note_vectors = embedding.vectors.drop(1)
      groups = cluster(NOTES, note_vectors)
      duplicate = groups.find { |group| group.members.length > 1 }
      cook = groups.find { |group| group.members.include?("Catering card DH-18465") }
      ranking = NOTES.each_with_index.map do |note, index|
        Ranked.new(title: note.title, score: cosine(query_vector, note_vectors.fetch(index)))
      end.sort_by { |row| -row.score }
      cook_row = ranking.find { |row| row.title == "Catering card DH-18465" }

      Result.new(
        clusters: groups,
        duplicate_titles: duplicate&.members || [],
        cook_cluster: cook&.members || [],
        winner: ranking.fetch(0).title,
        cook_score: cook_row.score,
        model_id: embedding.model,
        input_tokens: embedding.tokens.input,
        cost: embedding.cost.total
      )
    end

    def self.cluster(notes, vectors)
      assigned = []
      groups = []
      notes.each_with_index do |note, index|
        next if assigned.include?(index)

        members = [note.title]
        assigned << index
        notes.each_with_index do |other, other_index|
          next if assigned.include?(other_index)
          next if cosine(vectors.fetch(index), vectors.fetch(other_index)) < CLUSTER_FLOOR

          members << other.title
          assigned << other_index
        end
        groups << Cluster.new(title: members.fetch(0), members: members)
      end
      groups
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
  Multivitamin::Cassettes.play(__dir__, "galley_proofs") do
    result = BeirutGalleyProofs::GalleyProofs.conduct
  end

  puts result.winner
  result.clusters.each { |group| puts group.members.join(" / ") }
end
