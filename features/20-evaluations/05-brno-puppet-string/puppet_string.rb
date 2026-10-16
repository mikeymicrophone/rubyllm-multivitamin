# frozen_string_literal: true

# Evaluations · 05 · Brno puppet-string custom evaluator
#
# Teaches:
# - evaluation :names_the_bar declares a second semantic criterion.
# - Declared criteria replace implicit correctness unless correctness is named.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module BrnoPuppetString
  class StringCount < RubyLLM::Evaluation
    dataset File.expand_path("puppet_string.yml", __dir__)
    evaluator Multivitamin::Models::OPENAI_CHAT, provider: :openai
    evaluation :correctness
    evaluation :names_the_bar, "The answer names Eliska as the person holding the bar."

    INSTRUCTIONS = <<~TEXT.strip
      You are the string clerk at the puppet loft in Brno.
      Answer in two short sentences from the card only.
      Name 9 strings and Eliska.
    TEXT

    def perform(input)
      card = <<~TEXT.strip
        Puppet loft card, Brno, Friday 16 October 2026.
        Marionette B-7, 9 strings, bar held by Eliska.
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
  Multivitamin::Cassettes.play(__dir__, "puppet_string") do
    report = BrnoPuppetString::StringCount.conduct
  end
  puts report
end
