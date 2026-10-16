# frozen_string_literal: true

# Prompt caching · 11 · Tampere Finlayson card
#
# Teaches:
# - An Agent caching macro maps onto Chat#with_caching with no options.
# - The class holds the policy; Agent.new.ask runs it.
# - ttl: on this slug is slot 02. Empty caching still enables automatic.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module TampereFinlaysonCard
  class MillClerk < RubyLLM::Agent
    model Multivitamin::Models::OPENAI_CHAT, provider: :openai

    caching

    instructions <<~TEXT.strip
      You are the mill clerk at Finlayson in Tampere.
      Finlayson standing order 1: card TMP-2026-1016-F9 is the morning cotton lot.
      Finlayson standing order 2: Aino counts cones at 07:00.
      Finlayson standing order 3: do not mix the carded sliver with the combed.
      Answer in one short sentence from the board only.
      Name Aino and 07:00.
    TEXT

    temperature 0.2
  end

  class FinlaysonCard
    BOARD = "Board: Aino counts cones on card TMP-2026-1016-F9 at 07:00. When does Aino count?"

    Result = Struct.new(:brief, :agent_class, keyword_init: true)

    def self.conduct
      configure
      agent = open_agent
      brief = agent.ask(BOARD)

      Result.new(brief: brief.content, agent_class: agent.class.name)
    end

    def self.open_agent
      chosen = Multivitamin::Models.chat(provider: :openai)
      kwargs = { provider: chosen[:provider] }
      kwargs[:assume_model_exists] = true if chosen[:assume_model_exists]
      agent = MillClerk.new(model: chosen[:model], **kwargs)
      Multivitamin::Models.quiet_thinking(agent, provider: :openai)
      agent
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
  Multivitamin::Cassettes.play(__dir__, "finlayson_card") do
    result = TampereFinlaysonCard::FinlaysonCard.conduct
  end

  puts result.brief
end
