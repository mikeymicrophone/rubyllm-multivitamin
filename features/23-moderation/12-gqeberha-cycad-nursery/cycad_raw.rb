# frozen_string_literal: true

# Moderation · 12 · Gqeberha cycad nursery
#
# Teaches:
# - result.raw is the original provider body.
# - OpenAI assessments live under results[0].category_applied_input_types.
# - flagged_categories is still the application API.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module GqeberhaCycadNursery
  # The nursery clerk in Gqeberha screens a clean accession notice and
  # logs the raw assessments. The application still reads flagged? off
  # the wrapper.
  class CycadRaw
    NOTICE = <<~TEXT.strip
      Accession notice at a Gqeberha cycad nursery, Friday 16 October 2026.
      SANBI notes: https://www.sanbi.org/.
      Bed 4 holds Encephalartos altensteinii, 12 offsets, water at 06:50.
      When does bed 4 water?
    TEXT

    Result = Struct.new(
      :flagged,
      :raw_id,
      :applied_types,
      :score_keys,
      keyword_init: true
    )

    def self.conduct
      configure

      moderation = RubyLLM.moderate(NOTICE, **Multivitamin::Models.moderation)
      first = Array(moderation.raw&.[]("results")).fetch(0, {})

      Result.new(
        flagged: moderation.flagged?,
        raw_id: moderation.raw&.[]("id"),
        applied_types: first["category_applied_input_types"],
        score_keys: moderation.category_scores.keys.sort
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
  Multivitamin::Cassettes.play(__dir__, "cycad_raw") do
    result = GqeberhaCycadNursery::CycadRaw.conduct
  end

  puts "flagged=#{result.flagged} id=#{result.raw_id}"
  puts result.applied_types.inspect
end
