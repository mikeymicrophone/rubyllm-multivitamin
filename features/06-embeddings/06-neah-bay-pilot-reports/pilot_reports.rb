# frozen_string_literal: true

# Embeddings · 06 · Neah Bay pilot reports
#
# Teaches:
# - The same boarding note embedded twice is closer to itself than to a
#   different current note.
# - One batch holds the note, its copy, and the current.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module NeahBayPilotReports
  # The Puget Sound pilot on the ladder off Neah Bay files the boarding
  # note twice by accident, then files the afternoon current.
  class PilotReports
    BOARDING = <<~TEXT.strip
      Pilot boarding the bulk carrier Salish Grain off Neah Bay, 07:20.
      Ladder is 9 meters, 31.5 degrees, three-meter spreaders, no manropes.
      Combination light on, sea moderate from the west. Pilot: Kira.
    TEXT

    CURRENT = <<~TEXT.strip
      Afternoon current at the Neah Bay pilot station, 15:40.
      Ebb 2.4 kn setting west. Swell 6 ft at 8 seconds. No boarding until
      the swell drops below 4 ft.
    TEXT

    NOTES = [BOARDING, BOARDING, CURRENT].freeze

    Result = Struct.new(
      :self_score,
      :current_score,
      :model_id,
      :input_tokens,
      :cost,
      keyword_init: true
    )

    def self.conduct
      configure
      embedding = RubyLLM.embed(NOTES, **Multivitamin::Models.embed(provider: :openai))
      first, copy, current = embedding.vectors

      Result.new(
        self_score: cosine(first, copy),
        current_score: cosine(first, current),
        model_id: embedding.model,
        input_tokens: embedding.tokens.input,
        cost: embedding.cost.total
      )
    end

    def self.cosine(left, right)
      dot = 0.0
      na = 0.0
      nb = 0.0
      left.each_index do |index|
        dot += left[index] * right[index]
        na += left[index] * left[index]
        nb += right[index] * right[index]
      end
      dot / (Math.sqrt(na) * Math.sqrt(nb))
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 120
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "pilot_reports") do
    result = NeahBayPilotReports::PilotReports.conduct
  end

  puts "copy #{result.self_score.round(6)} current #{result.current_score.round(4)}"
end
