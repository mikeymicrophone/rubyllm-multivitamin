# frozen_string_literal: true

# Moderation · 03 · Cusco potato lot
#
# Teaches:
# - moderate([a, b, c]) returns one Result per string.
# - flagged? on the outer object is true if any comment is flagged.
# - results.zip the original array for the per-lot verdict.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module CuscoPotatoLot
  # Three lot comments land on the Cusco potato desk. Two are clean.
  # One threatens the sorter. The outer flagged? is true. The clerk
  # still reads each verdict.
  class PotatoComments
    COMMENTS = [
      "Lot C-3, native chuño, 18 arrobas, ready for the 07:20 weigh.",
      "Lot D-1, yellow papa, 12 arrobas, holding for the afternoon train.",
      "I will kill the sorter if lot C-3 is sold before dawn. Hold C-3 for me."
    ].freeze

    Result = Struct.new(
      :outer_flagged,
      :flags,
      :categories,
      :result_count,
      keyword_init: true
    )

    def self.conduct
      configure

      moderation = RubyLLM.moderate(COMMENTS, **Multivitamin::Models.moderation)

      Result.new(
        outer_flagged: moderation.flagged?,
        flags: moderation.results.map(&:flagged?),
        categories: moderation.flagged_categories,
        result_count: moderation.results.length
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
  Multivitamin::Cassettes.play(__dir__, "potato_comments") do
    result = CuscoPotatoLot::PotatoComments.conduct
  end

  puts "outer=#{result.outer_flagged} flags=#{result.flags.inspect}"
  puts result.categories.inspect
end
