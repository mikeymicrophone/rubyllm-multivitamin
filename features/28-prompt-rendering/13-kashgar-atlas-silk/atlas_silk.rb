# frozen_string_literal: true

# Prompt rendering · 13 · Kashgar atlas silk
#
# Teaches:
# - An Agent with no instructions macro auto-loads the conventional ERB.
# - That file can nest a path and pull a partial.
# - A follow-up ask still sees the rendered orders.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/prompts"

module KashgarAtlasSilk
  class IkatClerk < RubyLLM::Agent
    model Multivitamin::Models::OPENAI_CHAT, provider: :openai
    temperature 0.2
  end

  class AtlasSilk
    BOARD = "Board: Dilber warps lot KAS-2026-1016-A2 at 11:05. When does Dilber warp?"
    FOLLOW = "Does the standing order allow mixing the warp with the weft? Answer No or Yes."

    Result = Struct.new(:opening, :follow_up, :system, :roles, keyword_init: true)

    def self.conduct
      configure
      Multivitamin::Prompts.in_root(__dir__) do
        chosen = Multivitamin::Models.chat(provider: :openai)
        kwargs = { provider: chosen[:provider] }
        kwargs[:assume_model_exists] = true if chosen[:assume_model_exists]
        agent = IkatClerk.new(model: chosen[:model], **kwargs)
        Multivitamin::Models.quiet_thinking(agent, provider: :openai)
        opening = agent.ask(BOARD)
        follow_up = agent.ask(FOLLOW)
        system = agent.messages.find { |message| message.role == :system }
        Result.new(
          opening: opening.content,
          follow_up: follow_up.content,
          system: system&.content,
          roles: agent.messages.map(&:role)
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
  Multivitamin::Cassettes.play(__dir__, "atlas_silk") do
    result = KashgarAtlasSilk::AtlasSilk.conduct
  end

  puts result.opening
  puts result.follow_up
end
