# frozen_string_literal: true

# Extended thinking · 11 · Hawassa sidama coffee
#
# Teaches:
# - An Agent thinking macro maps onto Chat#with_thinking.
# - display: :summarized and effort: :low ride on the class.
# - Agent.new.ask runs that configuration.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module HawassaSidamaCoffee
  class MillClerk < RubyLLM::Agent
    model Multivitamin::Models::OPENAI_REASONING, provider: :openai
    thinking effort: :low, display: :summarized
    instructions <<~TEXT.strip
      You are the sidama clerk in Hawassa.
      Answer in one short sentence from the board only.
      Name Tigist and 06:20.
    TEXT
  end

  class SidamaCoffee
    BOARD = "Board: Tigist pulps lot HAW-2026-1016-C3 at 06:20. When does Tigist pulp?"

    Result = Struct.new(:brief, :thinking_text, :agent_class, keyword_init: true)

    def self.conduct
      configure
      agent = MillClerk.new(model: Multivitamin::Models::OPENAI_REASONING, provider: :openai)
      brief = agent.ask(BOARD)
      Result.new(
        brief: brief.content,
        thinking_text: brief.thinking&.text,
        agent_class: agent.class.name
      )
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
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "sidama") do
    result = HawassaSidamaCoffee::SidamaCoffee.conduct
  end

  puts result.brief
end
