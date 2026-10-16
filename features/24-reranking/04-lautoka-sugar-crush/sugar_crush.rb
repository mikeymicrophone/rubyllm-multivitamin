# frozen_string_literal: true

# Reranking · 04 · Lautoka sugar crush
#
# Teaches:
# - provider: :openrouter is explicit on the Voyage slug.
# - assume_model_exists: true keeps a registry miss from raising.
# - The mill query still puts the crush card first.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module LautokaSugarCrush
  class SugarCrush
    QUERY = "Which mill card is the overnight crush at Lautoka mill 2?"

    CARDS = [
      "Labasa mill is offline for the weekend shut.",
      "Lautoka mill 2 overnight crush, 22:00 to 05:30, mill 2 only.",
      "Rarawai juice heaters, not a crush.",
      "Lautoka bagasse pile, not a mill card."
    ].freeze

    Result = Struct.new(:index, :document, :model, keyword_init: true)

    def self.conduct
      configure

      ranked = RubyLLM.rerank(
        QUERY,
        CARDS,
        **Multivitamin::Models.rerank,
        provider: :openrouter,
        assume_model_exists: true
      )
      first = ranked.results.first

      Result.new(
        index: first.index,
        document: first.document,
        model: ranked.model
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
  Multivitamin::Cassettes.play(__dir__, "sugar_crush") do
    result = LautokaSugarCrush::SugarCrush.conduct
  end

  puts "index=#{result.index} model=#{result.model}"
  puts result.document
end
