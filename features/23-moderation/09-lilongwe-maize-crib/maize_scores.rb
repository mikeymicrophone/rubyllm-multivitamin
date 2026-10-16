# frozen_string_literal: true

# Moderation · 09 · Lilongwe maize crib
#
# Teaches:
# - A clean hail still has category_scores keys. The names are empty.
# - Bedrock is the provider that returns empty scores; OpenAI does not.
# - raw still holds the provider body.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module LilongweMaizeCrib
  # The crib clerk in Lilongwe screens a clean fill-notice. Omni-moderation
  # returns scores for every family and flags none of them. The notice
  # goes on the board.
  class MaizeScores
    NOTICE = <<~TEXT.strip
      Fill notice at a Lilongwe maize crib, Friday 16 October 2026.
      City notes: https://www.lilongwe.gov.mw/.
      Crib 2 takes 40 bags at 06:40. Crib 3 holds seed maize.
      When does crib 2 fill?
    TEXT

    Result = Struct.new(
      :flagged,
      :categories,
      :score_keys,
      :raw_keys,
      keyword_init: true
    )

    def self.conduct
      configure

      moderation = RubyLLM.moderate(NOTICE, **Multivitamin::Models.moderation)

      Result.new(
        flagged: moderation.flagged?,
        categories: moderation.flagged_categories,
        score_keys: moderation.category_scores.keys.sort,
        raw_keys: Array(moderation.raw&.[]("results")).fetch(0, {}).keys.sort
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
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
  Multivitamin::Cassettes.play(__dir__, "maize_scores") do
    result = LilongweMaizeCrib::MaizeScores.conduct
  end

  puts "flagged=#{result.flagged} scores=#{result.score_keys.inspect}"
end
