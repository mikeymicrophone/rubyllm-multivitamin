# frozen_string_literal: true

# Moderation · 07 · Georgetown demerara pan
#
# Teaches:
# - moderate(caption, with: image) sends both.
# - A clean boiling-pan card is not flagged.
# - The request body holds the caption and the image.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module GeorgetownDemeraraPan
  # The pan clerk in Georgetown screens a boiling-pan photograph with
  # its caption. Omni-moderation reads both. The pan is clean.
  class DemeraraPan
    PAN = File.expand_path("pan-card.png", __dir__)

    CAPTION = <<~TEXT.strip
      Boiling-pan card at a Georgetown demerara house, Friday 16 October 2026.
      Guyana tourism: https://www.guyanatourism.com/.
      Pan 2 at 118 C, strike expected at 14:10. Pan 3 holds molasses.
      Caption for the afternoon board.
    TEXT

    Result = Struct.new(:flagged, :categories, :model, keyword_init: true)

    def self.conduct
      configure

      moderation = RubyLLM.moderate(CAPTION, with: PAN, **Multivitamin::Models.moderation)

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
  Multivitamin::Cassettes.play(__dir__, "demerara_pan") do
    result = GeorgetownDemeraraPan::DemeraraPan.conduct
  end

  puts "flagged=#{result.flagged} model=#{result.model}"
end
