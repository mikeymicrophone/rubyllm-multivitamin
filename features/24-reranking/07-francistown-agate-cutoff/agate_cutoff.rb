# frozen_string_literal: true

# Reranking · 07 · Francistown agate cutoff
#
# Teaches:
# - Scores are provider-specific. Use them as a cutoff, not a probability.
# - The desk keeps lots whose score is at least the first-place score
#   minus a margin.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module FrancistownAgateCutoff
  class AgateCutoff
    QUERY = "Which lot is the banded agate for the cabochon tray?"

    LOTS = [
      "Lot 1, jasper crumbs, not agate.",
      "Lot 4, banded agate for the cabochon tray, 9 slices, Francistown.",
      "Lot 5, moss agate offcuts, too thin for cabochons.",
      "Lot 8, glass imitants, reject."
    ].freeze

    MARGIN = 0.15

    Result = Struct.new(:kept, :dropped, :top_score, keyword_init: true)

    def self.conduct
      configure

      ranked = RubyLLM.rerank(QUERY, LOTS, **Multivitamin::Models.rerank)
      top = ranked.results.first.score
      floor = top - MARGIN
      kept = ranked.results.select { |row| row.score >= floor }
      dropped = ranked.results.reject { |row| row.score >= floor }

      Result.new(
        kept: kept.map { |row| { index: row.index, score: row.score } },
        dropped: dropped.map { |row| { index: row.index, score: row.score } },
        top_score: top
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openrouter)
        config.max_retries = 0
        config.request_timeout = 60
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "agate_cutoff") do
    result = FrancistownAgateCutoff::AgateCutoff.conduct
  end

  puts "top=#{result.top_score} kept=#{result.kept.inspect}"
  puts "dropped=#{result.dropped.inspect}"
end
