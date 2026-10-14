# frozen_string_literal: true

# Embeddings · 01 · Point Wilson tide notes
#
# Teaches:
# - RubyLLM.embed turns one string into a vector on embedding.vectors.
# - A single string comes back as a flat Array of Float, not an array of vectors.
# - model, tokens.input, cost.total, and sparse_vectors are read off that result.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PointWilsonTideNotes
  # The tide clerk at Point Wilson embeds one posted note so later watches
  # can search the desk without rereading the board.
  class TideNote
    BOARD_NOTE = <<~TEXT.strip
      Point Wilson tide desk, Wednesday 14 October 2026.
      Station page: https://tidesandcurrents.noaa.gov/stationhome.html?id=9444900
      Low water 06:42, 0.4 ft above MLLW.
      High water 12:18, 8.1 ft.
      Alden clears the kelp ledge at 10:46.
      Retort can use the float at 08:57.
    TEXT

    Result = Struct.new(
      :vectors,
      :model_id,
      :sparse_vectors,
      :input_tokens,
      :cost,
      keyword_init: true
    )

    def self.conduct
      configure
      embedding = RubyLLM.embed(BOARD_NOTE, **embed_args)

      Result.new(
        vectors: embedding.vectors,
        model_id: embedding.model,
        sparse_vectors: embedding.sparse_vectors,
        input_tokens: embedding.tokens.input,
        cost: embedding.cost.total
      )
    end

    def self.embed_args
      Multivitamin::Models.embed(provider: :openai)
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
  Multivitamin::Cassettes.play(__dir__, "tide_note") do
    result = PointWilsonTideNotes::TideNote.conduct
  end

  puts "#{result.model_id} #{result.vectors.length} dimensions"
end
