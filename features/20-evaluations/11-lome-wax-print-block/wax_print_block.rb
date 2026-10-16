# frozen_string_literal: true

# Evaluations · 11 · Lomé wax-print progress callback
#
# Teaches:
# - Evaluation.run yields each completed Trial before the next case starts.
# - The block sees trial.test_case.name in dataset order.
# - Exceptions from the block propagate and stop the run.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module LomeWaxPrintBlock
  Result = Struct.new(:report, :progress, keyword_init: true)

  class BlockCount < RubyLLM::Evaluation
    dataset File.expand_path("wax_print_block.yml", __dir__)
    evaluator Multivitamin::Models::OPENAI_CHAT, provider: :openai

    INSTRUCTIONS = <<~TEXT.strip
      You are the block clerk at the wax-print yard in Lomé.
      Answer in one short sentence from the card only.
      Name 11 blocks and Afi.
    TEXT

    def perform(input)
      card = <<~TEXT.strip
        Lomé wax-print yard card, Friday 16 October 2026.
        11 blocks on the east table. Afi stamps the next length.
        #{input}
      TEXT
      chat = self.class.open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.ask(card)
    end

    def self.conduct
      configure
      progress = []
      report = run do |trial|
        progress << trial.test_case.name
      end
      Result.new(report: report, progress: progress)
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
  result = nil
  Multivitamin::Cassettes.play(__dir__, "wax_print_block") do
    result = LomeWaxPrintBlock::BlockCount.conduct
  end
  puts result.report
  puts "progress=#{result.progress.join(",")}"
end
