# frozen_string_literal: true

# Prompt rendering · 11 · Harar bookbinding
#
# Teaches:
# - instructions display_name: -> { } passes locals to the conventional prompt.
# - The lambda is evaluated when the agent is built.
# - The ERB file is app/prompts/<agent>/instructions.txt.erb.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/prompts"

module HararBookbinding
  class BinderyClerk < RubyLLM::Agent
    model Multivitamin::Models::OPENAI_CHAT, provider: :openai
    temperature 0.2
    instructions display_name: -> { "Zahra" }
  end

  class Bookbinding
    BOARD = "Board: Zahra sews quire HAR-2026-1016-Q4 at 08:50. When does Zahra sew?"

    Result = Struct.new(:brief, :system, :agent_class, keyword_init: true)

    def self.conduct
      configure
      Multivitamin::Prompts.in_root(__dir__) do
        chosen = Multivitamin::Models.chat(provider: :openai)
        kwargs = { provider: chosen[:provider] }
        kwargs[:assume_model_exists] = true if chosen[:assume_model_exists]
        agent = BinderyClerk.new(model: chosen[:model], **kwargs)
        Multivitamin::Models.quiet_thinking(agent, provider: :openai)
        brief = agent.ask(BOARD)
        system = agent.messages.find { |message| message.role == :system }
        Result.new(
          brief: brief.content,
          system: system&.content,
          agent_class: agent.class.name
        )
      end
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
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "bookbinding") do
    result = HararBookbinding::Bookbinding.conduct
  end

  puts result.brief
end
