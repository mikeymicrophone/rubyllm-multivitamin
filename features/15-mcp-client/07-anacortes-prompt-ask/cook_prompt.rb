# frozen_string_literal: true

# MCP client · 07 · Anacortes prompt through ask
#
# Teaches:
# - A server prompt is messages the server writes, filled in with arguments.
# - ask adds every turn of that prompt before the model answers.
# - prompts are chosen by people, like a slash command on the cook desk.

require "logger"
require "rbconfig"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AnacortesMcpPrompt
  SERVER = File.expand_path("../stdio_server.rb", __dir__)
  PROFILE = File.expand_path("desk.json", __dir__)

  class AnacortesRetortDesk < RubyLLM::MCP
    command RbConfig.ruby, SERVER, PROFILE
  end

  class CookPrompt
    INSTRUCTIONS = <<~TEXT.strip
      You are the retort clerk at the Anacortes cannery.
      Stay with the cook card in the prompt.
      Name the tender Retort.
      Mention 242 F and 74 minutes.
    TEXT

    Result = Struct.new(:answer, :roles, :prompt_name, :prompt_turns, keyword_init: true)

    def self.conduct
      configure
      desk = AnacortesRetortDesk.new
      brief = desk.prompt(:retort_cook_brief, basket: "3")
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      answer = chat.ask(brief)

      Result.new(
        answer: answer.content,
        roles: chat.messages.map(&:role),
        prompt_name: brief.name,
        prompt_turns: brief.messages.map(&:role)
      )
    ensure
      desk&.close
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
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
  Multivitamin::Cassettes.play(__dir__, "cook_prompt") do
    result = AnacortesMcpPrompt::CookPrompt.conduct
  end

  puts result.answer
end
