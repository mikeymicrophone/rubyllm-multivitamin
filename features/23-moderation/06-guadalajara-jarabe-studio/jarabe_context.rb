# frozen_string_literal: true

# Moderation · 06 · Guadalajara jarabe studio
#
# Teaches:
# - default_moderation_model on a RubyLLM.context selects the pinned id
#   without passing model: on the call.
# - The global default stays omni-moderation-latest.
# - Bedrock guardrails need AWS this catalog does not have.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module GuadalajaraJarabeStudio
  # The studio clerk in Guadalajara puts last winter's moderation pin on
  # a context so the jarabe card uses that id. The global default stays
  # latest. The card is clean.
  class JarabeContext
    CARD = <<~TEXT.strip
      Studio card at a Guadalajara jarabe rehearsal, Friday 16 October 2026.
      City notes: https://visitmexico.com/.
      First zapateado at 18:10. Second zapateado holds for Lupe.
      The skirt hems stay closed until the encore.
      When is the first zapateado?
    TEXT

    Result = Struct.new(:flagged, :model, :global_default, keyword_init: true)

    def self.conduct
      configure
      global_default = RubyLLM.config.default_moderation_model

      studio = RubyLLM.context do |config|
        config.default_moderation_model = Multivitamin::Models::OPENAI_MODERATION_PINNED
      end
      moderation = studio.moderate(CARD)

      Result.new(
        flagged: moderation.flagged?,
        model: moderation.model,
        global_default: global_default
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
  Multivitamin::Cassettes.play(__dir__, "jarabe_context") do
    result = GuadalajaraJarabeStudio::JarabeContext.conduct
  end

  puts "flagged=#{result.flagged} model=#{result.model} global=#{result.global_default}"
end
