# frozen_string_literal: true

# Prompt rendering · 07 · Yogyakarta wayang kulit
#
# Teaches:
# - An Agent with no conventional prompt and no instructions macro
#   starts without a system turn.
# - The first message is the dalang's question.
# - The missing file is not an error.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/prompts"

module YogyakartaWayangKulit
  class PuppetClerk < RubyLLM::Agent
    model Multivitamin::Models::OPENAI_CHAT, provider: :openai
    temperature 0.2
  end

  class WayangKulit
    BOARD = "Board: Wayan cues figure YGY-2026-1016-W1 at 19:30. When does Wayan cue? One short sentence."

    Result = Struct.new(:brief, :roles, :first_role, :agent_class, keyword_init: true)

    def self.conduct
      configure
      Multivitamin::Prompts.in_root(__dir__) do
        chosen = Multivitamin::Models.chat(provider: :openai)
        kwargs = { provider: chosen[:provider] }
        kwargs[:assume_model_exists] = true if chosen[:assume_model_exists]
        agent = PuppetClerk.new(model: chosen[:model], **kwargs)
        Multivitamin::Models.quiet_thinking(agent, provider: :openai)
        brief = agent.ask(BOARD)
        Result.new(
          brief: brief.content,
          roles: agent.messages.map(&:role),
          first_role: agent.messages.first.role,
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
  Multivitamin::Cassettes.play(__dir__, "wayang_kulit") do
    result = YogyakartaWayangKulit::WayangKulit.conduct
  end

  puts result.brief
  puts result.roles.inspect
end
