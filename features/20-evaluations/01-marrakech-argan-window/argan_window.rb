# frozen_string_literal: true

# Evaluations · 01 · Marrakech argan return window
#
# Teaches:
# - A RubyLLM::Evaluation subclass implements perform(input).
# - A YAML dataset beside the class lists name, inputs, and expected_output.
# - run returns a report. passed? is true when every case matches.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module MarrakechArganWindow
  # The press clerk in the Mellah reads two return questions against the
  # posted argan card. The grader checks meaning, not wording.
  class ReturnWindow < RubyLLM::Evaluation
    dataset File.expand_path("argan_window.yml", __dir__)
    evaluator Multivitamin::Models::OPENAI_CHAT, provider: :openai

    INSTRUCTIONS = <<~TEXT.strip
      You are the press clerk at the argan cooperative in the Mellah, Marrakech.
      Answer in one short sentence from the card only.
      Unopened tins may be returned within 30 days.
      Market-day discount tins are final.
      Name Souad and 30 days when the tin is unopened.
    TEXT

    def perform(input)
      chat = self.class.open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.ask(input)
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
  Multivitamin::Cassettes.play(__dir__, "argan_window") do
    report = MarrakechArganWindow::ReturnWindow.conduct
  end

  puts report
  puts "passed=#{report.passed?} cases=#{report.trials.map { |trial| trial.test_case.name }.join(",")}"
end
