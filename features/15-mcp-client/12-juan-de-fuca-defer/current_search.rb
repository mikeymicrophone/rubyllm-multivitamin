# frozen_string_literal: true

# MCP client · 12 · Juan de Fuca deferred tool search
#
# Teaches:
# - defer keeps a long server tool list out of the model's context.
# - with_mcp(..., defer: true) defers every tool of that server.
# - The provider searches, then the model calls the gate it found.

require "logger"
require "rbconfig"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module JuanDeFucaMcpDefer
  SERVER = File.expand_path("../stdio_server.rb", __dir__)
  PROFILE = File.expand_path("desk.json", __dir__)

  class JuanDeFucaChartDesk < RubyLLM::MCP
    command RbConfig.ruby, SERVER, PROFILE
    defer
  end

  class CurrentSearch
    INSTRUCTIONS = <<~TEXT.strip
      You are the chart clerk for the Strait of Juan de Fuca.
      Search the deferred tools for the Race Rocks current gate.
      Call that tool once.
      Answer in one sentence with the 2.8 kn figure.
      Name Race Rocks.
    TEXT

    GATE_QUESTION = <<~TEXT.strip
      Wednesday 14 October 2026 in the Strait of Juan de Fuca.
      Chart: https://charts.noaa.gov/RNCs/18465
      What is the ebb at the Race Rocks current gate, and should the inbound wait?
    TEXT

    Result = Struct.new(
      :answer,
      :roles,
      :tool_content,
      :deferred_names,
      :offered_names,
      keyword_init: true
    )

    def self.conduct
      configure
      desk = JuanDeFucaChartDesk.new
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_mcp(desk, defer: true)
      deferred_names = chat.deferred_tools.keys.map(&:to_s)
      offered_names = chat.tools.keys.map(&:to_s)
      answer = chat.ask(GATE_QUESTION)
      tool_message = chat.messages.find { |message| message.role == :tool }

      Result.new(
        answer: answer.content,
        roles: chat.messages.map(&:role),
        tool_content: tool_message&.content,
        deferred_names: deferred_names,
        offered_names: offered_names
      )
    ensure
      desk&.close
    end

    def self.open_chat
      RubyLLM.chat(
        model: Multivitamin::Models::OPENAI_CHAT_TOOL_SEARCH,
        provider: :openai,
        assume_model_exists: true
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        config.openai_api_key = Multivitamin::Models.api_key("OPENAI_API_KEY")
        config.openai_use_system_role = true
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
  Multivitamin::Cassettes.play(__dir__, "current_search") do
    result = JuanDeFucaMcpDefer::CurrentSearch.conduct
  end

  puts result.answer
end
