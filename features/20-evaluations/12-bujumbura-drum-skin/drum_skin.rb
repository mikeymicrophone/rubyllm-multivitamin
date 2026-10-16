# frozen_string_literal: true

# Evaluations · 12 · Bujumbura drum-skin failing case
#
# Teaches:
# - A trial fails when the spoken answer disagrees with expected_output.
# - report.passed? is false when any trial fails.
# - The fail reason sits on the correctness evaluation.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module BujumburaDrumSkin
  class SkinCount < RubyLLM::Evaluation
    dataset File.expand_path("drum_skin.yml", __dir__)
    evaluator Multivitamin::Models::OPENAI_CHAT, provider: :openai

    INSTRUCTIONS = <<~TEXT.strip
      You are the skin clerk at the drum loft in Bujumbura.
      Answer in one short sentence from the mis-posted card only.
      The card in your hand says 18 skins. Name 18 and Immaculee.
      Do not correct the card.
    TEXT

    def perform(input)
      card = <<~TEXT.strip
        Bujumbura drum-loft card, Friday 16 October 2026.
        The slip on the peg says 18 skins. Immaculee tensions the next hoop.
        The yard book, which you must not use, still lists 14.
        #{input}
      TEXT
      chat = self.class.open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.ask(card)
    end

    def self.conduct
      configure
      run
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

    def self.open_chat
      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat
    end

  end
end

if $PROGRAM_NAME == __FILE__
  report = nil
  Multivitamin::Cassettes.play(__dir__, "drum_skin") do
    report = BujumburaDrumSkin::SkinCount.conduct
  end
  puts report
end
