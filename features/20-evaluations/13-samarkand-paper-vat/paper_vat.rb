# frozen_string_literal: true

# Evaluations · 13 · Samarkand paper-vat desk capstone
#
# Teaches:
# - A desk eval can take Hash inputs, two cases, and a custom criterion.
# - run yields progress names; report.save writes tokens beside the verdicts.
# - Both cases must pass for report.passed?.

require "json"
require "logger"
require "tmpdir"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module SamarkandPaperVat
  Result = Struct.new(:report, :progress, :saved, :path, keyword_init: true)

  class VatDesk < RubyLLM::Evaluation
    dataset File.expand_path("paper_vat.yml", __dir__)
    evaluator Multivitamin::Models::OPENAI_CHAT, provider: :openai
    evaluation :correctness
    evaluation :names_the_vat, "The answer names vat SK-7 or Dilshod from the paper-vat card."

    INSTRUCTIONS = <<~TEXT.strip
      You are the vat clerk at the paper mill in Samarkand.
      Answer in two short sentences from the card only.
      Name vat SK-7, 27 sheets, 14:40, and Dilshod.
    TEXT

    def perform(input)
      card = <<~TEXT.strip
        Samarkand paper-vat card, Friday 16 October 2026.
        Vat #{input.fetch("vat")}, 27 sheets on the line, sizing at 14:40.
        Dilshod pulls the next mould and opens the kettle.
        #{input.fetch("question")}
      TEXT
      chat = self.class.open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.ask(card)
    end

    def self.conduct
      configure
      progress = []
      report = run { |trial| progress << trial.test_case.name }
      path = File.join(Dir.mktmpdir("samarkand-vat-"), "paper_vat.json")
      report.save(path)
      Result.new(report: report, progress: progress, saved: JSON.parse(File.read(path)), path: path)
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
  Multivitamin::Cassettes.play(__dir__, "paper_vat") do
    result = SamarkandPaperVat::VatDesk.conduct
  end
  puts result.report
  puts "progress=#{result.progress.join(",")} tokens=#{result.report.tokens.input}"
end
