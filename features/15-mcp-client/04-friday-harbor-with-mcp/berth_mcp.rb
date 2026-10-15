# frozen_string_literal: true

# MCP client · 04 · Friday Harbor with_mcp
#
# Teaches:
# - with_mcp connects a server to a chat.
# - chat.mcp reads the connected server by name.
# - with_mcp(nil) disconnects it.

require "logger"
require "rbconfig"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module FridayHarborWithMcp
  SERVER = File.expand_path("../stdio_server.rb", __dir__)
  PROFILE = File.expand_path("desk.json", __dir__)

  class FridayHarborBerthDesk < RubyLLM::MCP
    command RbConfig.ruby, SERVER, PROFILE
  end

  class BerthMcp
    INSTRUCTIONS = <<~TEXT.strip
      You are the berth clerk at Friday Harbor.
      Call berth_length once for berth 7.
      Answer in one sentence. Include the fender length the desk returns.
      Name the seiner Kulshan.
    TEXT

    BERTH_QUESTION = <<~TEXT.strip
      Wednesday 14 October 2026 at the Friday Harbor float.
      Marina office: https://www.portfridayharbor.org/
      The seiner Kulshan is 48 ft. Does berth 7 have room for her?
    TEXT

    Result = Struct.new(
      :answer,
      :roles,
      :tool_content,
      :connected_name,
      :cleared,
      keyword_init: true
    )

    def self.conduct
      configure
      desk = FridayHarborBerthDesk.new
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_mcp(desk)
      connected_name = chat.mcp.friday_harbor_berth_desk.name
      chat.with_tool_options(choice: "berth_length")

      answer = chat.ask(BERTH_QUESTION)
      tool_message = chat.messages.find { |message| message.role == :tool }
      chat.with_mcp(nil)

      Result.new(
        answer: answer.content,
        roles: chat.messages.map(&:role),
        tool_content: tool_message&.content,
        connected_name: connected_name,
        cleared: chat.mcp.to_a.empty?
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
  Multivitamin::Cassettes.play(__dir__, "berth_mcp") do
    result = FridayHarborWithMcp::BerthMcp.conduct
  end

  puts result.answer
end
