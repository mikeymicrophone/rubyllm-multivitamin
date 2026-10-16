# frozen_string_literal: true

# Reranking · 03 · Arequipa sillar quarry
#
# Teaches:
# - index maps a result back to the original record, not the ranked order.
# - The clerk keeps the quarry structs and reads them by index.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module ArequipaSillarQuarry
  Block = Struct.new(:bay, :stone, :note, keyword_init: true)

  # The quarry clerk in Arequipa keeps four sillar bays as structs. Voyage
  # ranks the notes. The desk reads the winning bay off the original array.
  class SillarQuarry
    BLOCKS = [
      Block.new(bay: "A", stone: "cream sillar", note: "Bay A, cream offcuts, too thin for the cathedral lintel."),
      Block.new(bay: "B", stone: "pink sillar", note: "Bay B, pink facing, held for a courtyard wall."),
      Block.new(bay: "C", stone: "white sillar", note: "Bay C, white sillar for the cathedral lintel, 14 blocks, Arequipa."),
      Block.new(bay: "D", stone: "ashlar mix", note: "Bay D, mixed ashlar, not graded.")
    ].freeze

    QUERY = "Which bay holds the white sillar for the cathedral lintel?"

    Result = Struct.new(:index, :bay, :stone, :note, keyword_init: true)

    def self.conduct
      configure

      ranked = RubyLLM.rerank(QUERY, BLOCKS.map(&:note), **Multivitamin::Models.rerank)
      winner = ranked.results.first
      block = BLOCKS.fetch(winner.index)

      Result.new(
        index: winner.index,
        bay: block.bay,
        stone: block.stone,
        note: block.note
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
  Multivitamin::Cassettes.play(__dir__, "sillar_quarry") do
    result = ArequipaSillarQuarry::SillarQuarry.conduct
  end

  puts "bay=#{result.bay} stone=#{result.stone} index=#{result.index}"
end
