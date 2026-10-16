# frozen_string_literal: true

# Moderation · 05 · Durban bunny chow
#
# Teaches:
# - model: selects a pinned OpenAI moderation id.
# - omni-moderation-2024-09-26 is not the default latest alias.
# - A clean counter hail is still not flagged.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module DurbanBunnyChow
  # The counter clerk in Durban pins a dated moderation model so a
  # replay of last winter's hail uses the same id. The bunny-chow card
  # is clean on that pin.
  class BunnyChow
    HAIL = <<~TEXT.strip
      Counter hail at a Durban bunny-chow shop, Friday 16 October 2026.
      City notes: https://www.durban.gov.za/.
      Mutton quarter ready at 11:30. Bean quarter holds for Sibusiso.
      The chilli oil stays closed until the afternoon rush.
      When is the mutton quarter ready?
    TEXT

    Result = Struct.new(:flagged, :model, :requested, keyword_init: true)

    def self.conduct
      configure

      moderation = RubyLLM.moderate(
        HAIL,
        **Multivitamin::Models.moderation(model: Multivitamin::Models::OPENAI_MODERATION_PINNED)
      )

      Result.new(
        flagged: moderation.flagged?,
        model: moderation.model,
        requested: Multivitamin::Models::OPENAI_MODERATION_PINNED
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
  Multivitamin::Cassettes.play(__dir__, "bunny_chow") do
    result = DurbanBunnyChow::BunnyChow.conduct
  end

  puts "flagged=#{result.flagged} model=#{result.model}"
end
