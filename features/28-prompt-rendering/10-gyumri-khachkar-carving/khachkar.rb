# frozen_string_literal: true

# Prompt rendering · 10 · Gyumri khachkar carving
#
# Teaches:
# - ask can take a rendered question template, not only a literal string.
# - Instructions and the question can come from different prompt files.
# - Locals in the question template are ERB, not a second provider call.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/prompts"

module GyumriKhachkarCarving
  class KhachkarCarving
    Result = Struct.new(:question, :brief, :roles, keyword_init: true)

    def self.conduct
      configure
      Multivitamin::Prompts.in_root(__dir__) do
        instructions = RubyLLM.render_prompt("khachkar/instructions")
        question = RubyLLM.render_prompt(
          "khachkar/question",
          carver: "Aram",
          lot: "GYU-2026-1016-K8"
        )
        chat = open_chat
        chat.with_instructions(instructions)
        chat.with_temperature(0.2)
        brief = chat.ask(question)
        Result.new(question: question, brief: brief.content, roles: chat.messages.map(&:role))
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
  Multivitamin::Cassettes.play(__dir__, "khachkar") do
    result = GyumriKhachkarCarving::KhachkarCarving.conduct
  end

  puts result.brief
end
