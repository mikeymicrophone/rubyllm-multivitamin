# frozen_string_literal: true

# Extended thinking · 03 · Hotan jade pebble
#
# Teaches:
# - budget: on gpt-5-nano is kept on chat.thinking but omitted from the
#   Responses reasoning object.
# - The same budget on Nemotron is reasoning.max_tokens.
# - One cassette holds both asks.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module HotanJadePebble
  class JadePebble
    OPENAI_INSTRUCTIONS = <<~TEXT.strip
      You are the jade clerk in Hotan.
      Answer in one short sentence from the board only.
      Name Gulnisa and 09:40.
    TEXT

    OPENROUTER_INSTRUCTIONS = OPENAI_INSTRUCTIONS

    BOARD = "Board: Gulnisa grades pebble HOT-2026-1016-J2 at 09:40. When does Gulnisa grade?"

    Result = Struct.new(
      :openai_brief,
      :openrouter_brief,
      :openai_budget,
      :openrouter_budget,
      keyword_init: true
    )

    def self.conduct
      openai_brief, openai_budget = openai_ask
      openrouter_brief, openrouter_budget = openrouter_ask
      Result.new(
        openai_brief: openai_brief,
        openrouter_brief: openrouter_brief,
        openai_budget: openai_budget,
        openrouter_budget: openrouter_budget
      )
    end

    def self.openai_ask
      configure_openai
      chat = RubyLLM.chat(model: Multivitamin::Models::OPENAI_REASONING, provider: :openai)
      chat.with_thinking(budget: 1024)
      chat.with_instructions(OPENAI_INSTRUCTIONS)
      brief = chat.ask(BOARD)
      [brief.content, chat.thinking]
    end

    def self.openrouter_ask
      configure_openrouter
      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openrouter))
      chat.with_thinking(budget: 1024)
      chat.with_instructions(OPENROUTER_INSTRUCTIONS)
      chat.with_temperature(0.2)
      brief = chat.ask(BOARD)
      [brief.content, chat.thinking]
    end

    def self.configure_openai
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 180
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end

    def self.configure_openrouter
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openrouter)
        config.max_retries = 0
        config.request_timeout = 180
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "jade") do
    result = HotanJadePebble::JadePebble.conduct
  end

  puts result.openai_brief
  puts result.openrouter_brief
end
