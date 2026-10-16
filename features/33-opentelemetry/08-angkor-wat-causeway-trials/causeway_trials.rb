# frozen_string_literal: true

# OpenTelemetry · 08 · Angkor Wat causeway trials
#
# Teaches:
# - Evaluation trials create workflows without a manual workflow wrapper.
# - A YAML dataset supplies structured inputs; case/in destructures the inspection.
# - evaluator false retains Ruby assertions and avoids a second model grader.

require "json"
require_relative "../../../support/tracing"

module AngkorWatCausewayTrials
  class CausewayInspection < RubyLLM::Evaluation
    dataset File.expand_path("causeway_cards.yml", __dir__)
    evaluator false

    def perform(card)
      case card.transform_keys(&:to_sym)
      in { section:, keeper:, reopen: }
        RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
          .with_instructions("Brief the Angkor Wat causeway from the posted card only. Repeat the keeper and reopening time.")
          .ask("#{section} causeway: #{keeper} replaces the loose stone; reopen at #{reopen}. Brief the relief.")
      end
    end

    def assertions
      assert_includes output.to_s, input.fetch("keeper")
      assert_includes output.to_s, input.fetch("reopen")
    end

    def self.conduct
      Multivitamin::Runtime.configure(provider: :openai)
      Multivitamin::Tracing.capture { run }
    end
  end
end

if $PROGRAM_NAME == __FILE__
  capture = Multivitamin::Cassettes.play(__dir__, "causeway_trials") do
    AngkorWatCausewayTrials::CausewayInspection.conduct
  end
  puts capture.value.inspect
  puts capture.spans.map(&:name)
end
