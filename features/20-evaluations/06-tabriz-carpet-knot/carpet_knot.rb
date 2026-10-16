# frozen_string_literal: true

# Evaluations · 06 · Tabriz carpet-knot Judge grader
#
# Teaches:
# - evaluator may be a RubyLLM::Judge class.
# - evaluation :agrees, minimum: 0.5 turns a probability into a pass.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module TabrizCarpetKnot
  class KnotJudge < RubyLLM::Judge
    model Multivitamin::Models::OPENAI_JUDGMENT, provider: :openai
    probability :agrees, "Does the clerk's answer agree with the expected knot card?"
  end

  class KnotCount < RubyLLM::Evaluation
    dataset File.expand_path("carpet_knot.yml", __dir__)
    evaluator KnotJudge
    evaluation :agrees, minimum: 0.5

    INSTRUCTIONS = <<~TEXT.strip
      You are the knot clerk at the carpet loft in Tabriz.
      Answer in two short sentences from the card only.
      Name 86 knots and Farhad.
    TEXT

    def perform(input)
      card = <<~TEXT.strip
        Tabriz north-loom card, Friday 16 October 2026.
        86 knots on the north loom. Farhad ties the next row.
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
        config.request_timeout = 180
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
  Multivitamin::Cassettes.play(__dir__, "carpet_knot") do
    report = TabrizCarpetKnot::KnotCount.conduct
  end
  puts report
end
