# frozen_string_literal: true

# MCP client · 09 · Bremerton listen and after_change
#
# Teaches:
# - after_change runs when the server announces a list change.
# - listen hears those announcements between requests.
# - RubyLLM forgets the tool list, so the next turn lists them again.

require "logger"
require "rbconfig"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module BremertonMcpListen
  SERVER = File.expand_path("../stdio_server.rb", __dir__)
  PROFILE = File.expand_path("desk.json", __dir__)

  class BremertonDryDockDesk < RubyLLM::MCP
    command RbConfig.ruby, SERVER, PROFILE
    after_change :record_change

    def heard
      @heard ||= []
    end

    private

    def record_change(change)
      heard << change
    end
  end

  class GateListen
    INSTRUCTIONS = <<~TEXT.strip
      You are the dry dock clerk at Bremerton.
      Call dry_dock_sill once.
      Answer in one sentence. Include 18.4 ft.
      Name the tug Skookum.
    TEXT

    SILL_QUESTION = <<~TEXT.strip
      Wednesday 14 October 2026 at Puget Sound Naval Shipyard.
      Yard: https://www.navsea.navy.mil/Home/Shipyards/PSNS-IMF/
      The tug Skookum is waiting on the sill. What depth is posted?
    TEXT

    Result = Struct.new(
      :answer,
      :roles,
      :tool_content,
      :heard,
      :names_before,
      :names_after,
      keyword_init: true
    )

    def self.conduct
      configure
      desk = BremertonDryDockDesk.new
      names_before = desk.tools.map(&:name)
      desk.listen
      desk.post_sill_card
      wait_for_change(desk)
      names_after = desk.tools.map(&:name)
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_mcp(desk)
      chat.with_tool_options(choice: "dry_dock_sill")
      answer = chat.ask(SILL_QUESTION)
      tool_message = chat.messages.find { |message| message.role == :tool }

      Result.new(
        answer: answer.content,
        roles: chat.messages.map(&:role),
        tool_content: tool_message&.content,
        heard: desk.heard,
        names_before: names_before,
        names_after: names_after
      )
    ensure
      desk&.close
    end

    def self.wait_for_change(desk)
      40.times do
        return if desk.heard.include?(:tools)

        sleep 0.05
      end
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
  Multivitamin::Cassettes.play(__dir__, "gate_listen") do
    result = BremertonMcpListen::GateListen.conduct
  end

  puts result.answer
end
