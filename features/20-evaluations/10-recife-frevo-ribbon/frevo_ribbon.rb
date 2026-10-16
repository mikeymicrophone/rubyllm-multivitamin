# frozen_string_literal: true

# Evaluations · 10 · Recife frevo-ribbon expected versus output
#
# Teaches:
# - evaluator false skips the chat grader and runs only Ruby assertions.
# - assertions can compare output to expected_output on the same instance.
# - trial.output is the spoken answer; trial.test_case.expected_output is the card.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module RecifeFrevoRibbon
  class RibbonCount < RubyLLM::Evaluation
    dataset File.expand_path("frevo_ribbon.yml", __dir__)
    evaluator false

    INSTRUCTIONS = <<~TEXT.strip
      You are the ribbon clerk at the frevo loft in Recife.
      Answer in one short sentence from the card only.
      Name 36 ribbons and Moacir.
    TEXT

    def perform(input)
      card = <<~TEXT.strip
        Recife frevo loft card, Friday 16 October 2026.
        36 ribbons on the carnival table. Moacir ties the next sash.
        #{input}
      TEXT
      chat = self.class.open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.ask(card)
    end

    def assertions
      assert_match(/Moacir/, output.to_s)
      assert_match(/36/, output.to_s)
      assert_match(/Moacir/, expected_output.to_s)
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
  Multivitamin::Cassettes.play(__dir__, "frevo_ribbon") do
    report = RecifeFrevoRibbon::RibbonCount.conduct
  end
  puts report
end
