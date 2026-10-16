# frozen_string_literal: true

# Prompt rendering · 04 · Mostar copper pot
#
# Teaches:
# - Nested prompt names resolve under app/prompts.
# - The full filename with .txt.erb is accepted too.
# - Both paths render the same coppersmith card.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/prompts"

module MostarCopperPot
  class CopperPot
    BOARD = "Board: Emir hammers pot MST-2026-1016-C5 at 10:20. When does Emir hammer?"

    Result = Struct.new(:nested, :full_name, :brief, :roles, keyword_init: true)

    def self.conduct
      configure
      Multivitamin::Prompts.in_root(__dir__) do
        nested = RubyLLM.render_prompt("coppersmith/instructions", smith: "Emir", lot: "MST-2026-1016-C5")
        full_name = RubyLLM.render_prompt(
          "coppersmith/instructions.txt.erb",
          smith: "Emir",
          lot: "MST-2026-1016-C5"
        )
        chat = open_chat
        chat.with_instructions(nested)
        chat.with_temperature(0.2)
        brief = chat.ask(BOARD)
        Result.new(nested: nested, full_name: full_name, brief: brief.content, roles: chat.messages.map(&:role))
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
  Multivitamin::Cassettes.play(__dir__, "copper_pot") do
    result = MostarCopperPot::CopperPot.conduct
  end

  puts result.brief
end
