# frozen_string_literal: true

# Evaluations · 07 · Guayaquil toquilla-brim Minitest helper
#
# Teaches:
# - extend RubyLLM::Evaluation::Minitest and evaluates adds one test per case.
# - The helper uses the same runner as Evaluation.run.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module GuayaquilToquillaBrim
  class BrimWidth < RubyLLM::Evaluation
    dataset File.expand_path("toquilla_brim.yml", __dir__)
    evaluator Multivitamin::Models::OPENAI_CHAT, provider: :openai

    INSTRUCTIONS = <<~TEXT.strip
      You are the brim clerk at the toquilla loft in Guayaquil.
      Answer in one short sentence from the card only.
      Name 12 centimetres and Dolores.
    TEXT

    def perform(input)
      card = <<~TEXT.strip
        Toquilla loft card, Guayaquil, Friday 16 October 2026.
        Hat TQ-4, brim 12 centimetres, blocked by Dolores.
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
  Multivitamin::Cassettes.play(__dir__, "toquilla_brim") do
    report = GuayaquilToquillaBrim::BrimWidth.conduct
  end
  puts report
end
