# frozen_string_literal: true

# MCP client · 02 · New Dungeness inline MCP
#
# Teaches:
# - RubyLLM.mcp builds a server from keywords when a class is not worth writing.
# - url: still connects over Streamable HTTP.
# - The inline object is what with_mcp hands the chat.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module NewDungenessInlineMcp
  class LampCurrentDocs
    INSTRUCTIONS = <<~TEXT.strip
      You are the lens keeper at New Dungeness Light Station.
      Call microsoft_docs_search once for Azure Monitor custom metrics.
      Answer in two short sentences.
      Name the Fresnel lamp.
      Repeat a phrase the tool returned.
      Do not invent a metric name.
    TEXT

    LAMP_QUESTION = <<~TEXT.strip
      Wednesday 14 October 2026 in the New Dungeness lens cabinet.
      Station notes: https://www.nps.gov/places/new-dungeness-light-station.htm
      Docs: https://learn.microsoft.com/azure/azure-monitor/essentials/metrics-custom-overview
      The Fresnel lamp current logger posts custom metrics to Azure Monitor.
      Which Microsoft Learn page covers custom metrics, so the watch can chart the lamp amperage?
    TEXT

    Result = Struct.new(:answer, :roles, :tool_content, :server_name, keyword_init: true)

    def self.conduct
      configure
      docs = RubyLLM.mcp(url: "https://learn.microsoft.com/api/mcp")
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_mcp(docs)
      chat.with_tool_options(choice: "microsoft_docs_search")

      answer = chat.ask(LAMP_QUESTION)
      tool_message = chat.messages.find { |message| message.role == :tool }

      Result.new(
        answer: answer.content,
        roles: chat.messages.map(&:role),
        tool_content: tool_message&.content,
        server_name: docs.name
      )
    ensure
      docs&.close
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
  Multivitamin::Cassettes.play(__dir__, "lamp_current_docs") do
    result = NewDungenessInlineMcp::LampCurrentDocs.conduct
  end

  puts result.answer
end
