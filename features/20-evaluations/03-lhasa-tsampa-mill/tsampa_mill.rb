# frozen_string_literal: true

# Evaluations · 03 · Lhasa tsampa-mill multi-turn
#
# Teaches:
# - perform may run two asks and return the Chat.
# - The grader sees every message, not only the last sentence.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module LhasaTsampaMill
  class MillTurns < RubyLLM::Evaluation
    dataset File.expand_path("tsampa_mill.yml", __dir__)
    evaluator Multivitamin::Models::OPENAI_CHAT, provider: :openai

    INSTRUCTIONS = <<~TEXT.strip
      You are the mill clerk at the tsampa mill below the Barkhor, Lhasa.
      Keep each reply to two short sentences.
      Name 1,080 sacks and 09:15.
      Do not invent a gate time.
    TEXT

    def perform(input)
      chat = self.class.open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.ask(input.fetch("opening"))
      chat.ask(input.fetch("follow_up"))
      chat
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
  Multivitamin::Cassettes.play(__dir__, "tsampa_mill") do
    report = LhasaTsampaMill::MillTurns.conduct
  end
  puts report
end
