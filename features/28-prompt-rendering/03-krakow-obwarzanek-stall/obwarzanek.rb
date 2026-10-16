# frozen_string_literal: true

# Prompt rendering · 03 · Kraków obwarzanek stall
#
# Teaches:
# - A prompt file does not need locals.
# - render_prompt("reviewer") resolves reviewer.txt.erb at the prompt root.
# - The rendered string is still a with_instructions argument.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/prompts"

module KrakowObwarzanekStall
  class ObwarzanekStall
    BOARD = "Board: Zofia bags stall KRK-2026-1016-O2 at 06:40. When does Zofia bag?"

    Result = Struct.new(:rendered, :brief, :roles, keyword_init: true)

    def self.conduct
      configure
      Multivitamin::Prompts.in_root(__dir__) do
        rendered = RubyLLM.render_prompt("obwarzanek")
        chat = open_chat
        chat.with_instructions(rendered)
        chat.with_temperature(0.2)
        brief = chat.ask(BOARD)
        Result.new(rendered: rendered, brief: brief.content, roles: chat.messages.map(&:role))
      end
    end

    def self.open_chat
      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat
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
  Multivitamin::Cassettes.play(__dir__, "obwarzanek") do
    result = KrakowObwarzanekStall::ObwarzanekStall.conduct
  end

  puts result.brief
end
