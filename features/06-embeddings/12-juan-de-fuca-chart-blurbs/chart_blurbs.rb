# frozen_string_literal: true

# Embeddings · 12 · Juan de Fuca chart blurbs
#
# Teaches:
# - Near-duplicate chart corrections cluster together.
# - A blurb that shares a buoy name but not the move stays out of that cluster.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module JuanDeFucaChartBlurbs
  # The mate correcting NOAA chart 18465 clusters three blurbs about buoy DH
  # and keeps a same-words fog signal note in its own cluster.
  class ChartBlurbs
    CLUSTER_FLOOR = 0.8

    Note = Struct.new(:title, :body, keyword_init: true)

    NOTES = [
      Note.new(
        title: "DH moved northwest",
        body: "NOAA chart 18465. Dungeness Spit lighted bell buoy DH is moved 300 yards northwest of the printed symbol. Do not use the old symbol for a fix."
      ),
      Note.new(
        title: "DH shifted 300 yards",
        body: "Chart 18465, Strait of Juan de Fuca. Lighted bell buoy DH has been shifted 300 yards to the northwest. The printed position is stale."
      ),
      Note.new(
        title: "DH fog signal still 2 seconds",
        body: "NOAA chart 18465. Dungeness Spit lighted bell buoy DH fog signal remains one 2-second blast every 20 seconds. The horn house ashore is not the buoy."
      )
    ].freeze

    Cluster = Struct.new(:title, :members, keyword_init: true)
    Result = Struct.new(:clusters, :duplicate_titles, :horn_cluster, :model_id, :input_tokens, :cost, keyword_init: true)

    def self.conduct
      configure
      embedding = RubyLLM.embed(NOTES.map(&:body), **Multivitamin::Models.embed(provider: :openai))
      groups = cluster(NOTES, embedding.vectors)
      duplicate = groups.find { |group| group.members.length > 1 }
      horn = groups.find { |group| group.members.include?("DH fog signal still 2 seconds") }

      Result.new(
        clusters: groups,
        duplicate_titles: duplicate&.members || [],
        horn_cluster: horn&.members || [],
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
  Multivitamin::Cassettes.play(__dir__, "chart_blurbs") do
    result = JuanDeFucaChartBlurbs::ChartBlurbs.conduct
  end

  result.clusters.each { |group| puts "#{group.members.join(' / ')}" }
end
