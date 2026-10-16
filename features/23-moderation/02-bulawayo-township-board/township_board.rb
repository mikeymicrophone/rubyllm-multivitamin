# frozen_string_literal: true

# Moderation · 02 · Bulawayo township board
#
# Teaches:
# - flagged? is true when the provider flags a comment.
# - flagged_categories names the families. category_scores keeps the
#   highest score per family.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module BulawayoTownshipBoard
  # A threatening classifieds slip lands on the township board in Bulawayo.
  # The clerk screens it before it is pinned. Omni-moderation flags the
  # violence and the desk holds the slip.
  class TownshipBoard
    SLIP = <<~TEXT.strip
      Classifieds slip posted at the Makokoba township board, Bulawayo,
      Friday 16 October 2026.
      City notes: https://www.bulawayo.gov.zw/.
      Stall 4 comment: I am going to kill the stall clerk if stall 4 is
      gone at dawn. Do not take that stall from me.
      Hold this slip. Do not pin it.
    TEXT

    Result = Struct.new(
      :flagged,
      :categories,
      :violence_score,
      :model,
      keyword_init: true
    )

    def self.conduct
      configure

      moderation = RubyLLM.moderate(SLIP, **Multivitamin::Models.moderation)

      Result.new(
        flagged: moderation.flagged?,
        categories: moderation.flagged_categories,
        violence_score: moderation.category_scores["violence"],
        model: moderation.model
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
  Multivitamin::Cassettes.play(__dir__, "township_board") do
    result = BulawayoTownshipBoard::TownshipBoard.conduct
  end

  puts "flagged=#{result.flagged} categories=#{result.categories.inspect}"
end
