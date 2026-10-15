# frozen_string_literal: true

# MCP client · 05 · Neah Bay agent mcp macro
#
# Teaches:
# - An Agent declares servers with mcp, the way it declares tools.
# - A block runs when the chat is built.
# - Agent.chat.ask uses those servers without a separate with_mcp.

require "logger"
require "rbconfig"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module NeahBayAgentMcp
  SERVER = File.expand_path("../stdio_server.rb", __dir__)
  PROFILE = File.expand_path("desk.json", __dir__)

  class NeahBayPilotDesk < RubyLLM::MCP
    command RbConfig.ruby, SERVER, PROFILE
  end

  class PilotBoardingClerk < RubyLLM::Agent
    model Multivitamin::Models::OPENAI_CHAT, provider: :openai
    temperature 0.2
    instructions <<~TEXT.strip
      You are the pilot clerk at Neah Bay.
      Call pilot_ladder once.
      Answer in one sentence. Include the boarding time the desk returns.
      Name the cutter Makah.
    TEXT
    mcp { NeahBayPilotDesk.new }
    tool_options choice: "pilot_ladder"
  end

  class PilotAgent
    LADDER_QUESTION = <<~TEXT.strip
      Wednesday 14 October 2026 off Waadah Island.
      Station: https://www.makah.com/
      When does the cutter Makah board the inbound ship on the Neah Bay ladder?
    TEXT

    Result = Struct.new(:answer, :roles, :tool_content, :server_names, keyword_init: true)

    def self.conduct
      configure
      chat = PilotBoardingClerk.chat
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      answer = chat.ask(LADDER_QUESTION)
      tool_message = chat.messages.find { |message| message.role == :tool }
      desk = chat.mcp.neah_bay_pilot_desk

      Result.new(
        answer: answer.content,
        roles: chat.messages.map(&:role),
        tool_content: tool_message&.content,
        server_names: chat.mcp.to_a.map(&:name)
      )
    ensure
      desk&.close
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
  Multivitamin::Cassettes.play(__dir__, "pilot_agent") do
    result = NeahBayAgentMcp::PilotAgent.conduct
  end

  puts result.answer
end
