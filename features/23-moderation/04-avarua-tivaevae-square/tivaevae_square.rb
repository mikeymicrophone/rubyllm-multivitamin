# frozen_string_literal: true

# Moderation · 04 · Avarua tivaevae square
#
# Teaches:
# - moderate(with: path) screens an image without a caption.
# - A clean studio square is not flagged.
# - The attachment is an image. WAV is a later slot.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AvaruaTivaevaeSquare
  # The studio clerk in Avarua screens a tivaevae square photograph
  # before it goes on the afternoon board. Omni-moderation reads the
  # image. The square is clean.
  class TivaevaeSquare
    SQUARE = File.expand_path("tivaevae-square.png", __dir__)

    Result = Struct.new(:flagged, :categories, :model, keyword_init: true)

    def self.conduct
      configure

      moderation = RubyLLM.moderate(with: SQUARE, **Multivitamin::Models.moderation)

      Result.new(
        flagged: moderation.flagged?,
        categories: moderation.flagged_categories,
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
  Multivitamin::Cassettes.play(__dir__, "tivaevae_square") do
    result = AvaruaTivaevaeSquare::TivaevaeSquare.conduct
  end

  puts "flagged=#{result.flagged} model=#{result.model}"
end
