# frozen_string_literal: true

# Embeddings · 04 · Abidjan cacao lot
#
# Teaches:
# - dimensions: cuts the vector when the model accepts it.
# - The default call omits dimensions and comes back 1536 long.
# - The shortened call sends dimensions and comes back that length.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AbidjanCacaoLot
  # The shed clerk at Treichville keeps two copies of one ferment note:
  # the full 1536-wide vector for the plant archive, and a 512-wide vector
  # for the pocket ledger.
  class CacaoVectors
    DEVIATION = <<~TEXT.strip
      Abidjan cacao shed, lot CIV-314, Wednesday 14 October 2026.
      Heap 3 of the morning Forastero dropped 4 C below the 28 C ferment
      for 90 seconds after the paddle seized. Hold restored at 11:18.
      Clerk: Aya. Do not mix with the Trinitario heap on pad 1.
    TEXT

    POCKET_WIDTH = 512

    Result = Struct.new(
      :archive_length,
      :pocket_length,
      :archive_tokens,
      :pocket_tokens,
      :model_id,
      :cost,
      keyword_init: true
    )

    def self.conduct
      configure
      args = Multivitamin::Models.embed(provider: :openai)
      archive = RubyLLM.embed(DEVIATION, **args)
      pocket = RubyLLM.embed(DEVIATION, **args, dimensions: POCKET_WIDTH)

      Result.new(
        archive_length: archive.vectors.length,
        pocket_length: pocket.vectors.length,
        archive_tokens: archive.tokens.input,
        pocket_tokens: pocket.tokens.input,
        model_id: pocket.model,
        cost: archive.cost.total + pocket.cost.total
      )
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
  Multivitamin::Cassettes.play(__dir__, "cacao_vectors") do
    result = AbidjanCacaoLot::CacaoVectors.conduct
  end

  puts "archive #{result.archive_length} pocket #{result.pocket_length}"
end
