# frozen_string_literal: true

# Moderation · 01 · Tamale groundnut paste
#
# Teaches:
# - RubyLLM.moderate screens a string on the default OpenAI model.
# - flagged? is false on a clean mill hail.
# - The result is a RubyLLM::Moderation with one Result.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module TamaleGroundnutPaste
  # The mill clerk in Tamale posts the morning groundnut-paste hail.
  # Omni-moderation lets it through. The desk does not hold a clean card.
  class GroundnutHail
    HAIL = <<~TEXT.strip
      Morning hail at the Tamale groundnut-paste mill, Friday 16 October 2026.
      Visit Ghana: https://visitghana.com/.
      Vat 3 is open for the 07:15 grind. Amina's 40 kg lot of red-skin
      groundnuts is next. The press stays closed until the afternoon bell.
      When does Amina's lot go on vat 3?
    TEXT

    Result = Struct.new(
      :flagged,
      :categories,
      :score_keys,
      :result_count,
      :model,
      keyword_init: true
    )

    def self.conduct
      configure

      moderation = RubyLLM.moderate(HAIL, **Multivitamin::Models.moderation)

      Result.new(
        flagged: moderation.flagged?,
        categories: moderation.flagged_categories,
        score_keys: moderation.category_scores.keys.sort,
        result_count: moderation.results.length,
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
  Multivitamin::Cassettes.play(__dir__, "groundnut_hail") do
    result = TamaleGroundnutPaste::GroundnutHail.conduct
  end

  puts "flagged=#{result.flagged} model=#{result.model}"
  puts result.categories.inspect
end
