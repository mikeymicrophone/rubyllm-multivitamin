# frozen_string_literal: true

# Evaluations · 09 · Yazd windcatcher JSON report tokens
#
# Teaches:
# - report.save writes tokens and cost beside the trial verdicts.
# - report.tokens sums the clerk and the grader.

require "json"
require "logger"
require "tmpdir"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module YazdWindcatcherDraft
  class DraftWindow < RubyLLM::Evaluation
    dataset File.expand_path("windcatcher_draft.yml", __dir__)
    evaluator Multivitamin::Models::OPENAI_CHAT, provider: :openai

    INSTRUCTIONS = <<~TEXT.strip
      You are the draft clerk at a windcatcher house in Yazd.
      Answer in one short sentence from the card only.
      Name 10:20 and Shirin.
    TEXT

    def perform(input)
      card = <<~TEXT.strip
        Yazd north-windcatcher card, Friday 16 October 2026.
        Draw at 10:20. Shirin opens the vent.
        #{input}
      TEXT
      chat = self.class.open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.ask(card)
    end

    Result = Struct.new(:report, :path, :saved, keyword_init: true)

    def self.conduct
      configure
      report = run
      path = File.join(Dir.mktmpdir("yazd-draft-"), "windcatcher.json")
      report.save(path)
      Result.new(report: report, path: path, saved: JSON.parse(File.read(path)))
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
  Multivitamin::Cassettes.play(__dir__, "windcatcher_draft") do
    result = YazdWindcatcherDraft::DraftWindow.conduct
  end
  puts result.report
  puts "tokens=#{result.report.tokens.input} saved=#{result.path}"
end
