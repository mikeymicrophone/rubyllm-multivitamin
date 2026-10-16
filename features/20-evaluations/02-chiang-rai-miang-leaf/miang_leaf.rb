# frozen_string_literal: true

# Evaluations · 02 · Chiang Rai miang-leaf structured inputs
#
# Teaches:
# - Dataset inputs may be a Hash. perform receives that Hash.
# - The clerk builds the question from lot, grade, and question keys.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module ChiangRaiMiangLeaf
  class LeafGrade < RubyLLM::Evaluation
    dataset File.expand_path("miang_leaf.yml", __dir__)
    evaluator Multivitamin::Models::OPENAI_CHAT, provider: :openai

    INSTRUCTIONS = <<~TEXT.strip
      You are the leaf clerk at the miang yard outside Chiang Rai.
      Answer in one short sentence from the card only.
      Name lot CR-18 and 42 leaves.
    TEXT

    def perform(input)
      card = <<~TEXT.strip
        Miang rack card, Chiang Rai, Friday 16 October 2026.
        Lot #{input.fetch("lot")}, grade #{input.fetch("grade")}, 42 leaves on the south rack.
        #{input.fetch("question")}
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
  Multivitamin::Cassettes.play(__dir__, "miang_leaf") do
    report = ChiangRaiMiangLeaf::LeafGrade.conduct
  end
  puts report
end
