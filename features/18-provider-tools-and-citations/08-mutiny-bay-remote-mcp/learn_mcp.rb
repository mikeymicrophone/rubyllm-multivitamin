# frozen_string_literal: true

# Provider tools and citations · 08 · Mutiny Bay remote MCP
#
# Teaches:
# - with_provider_tools(mcp: { name:, url: }) is a provider-hosted MCP
#   connector, not RubyLLM::MCP.
# - url becomes server_url and name becomes server_label.
# - require_approval: "never" lets the allowed tool run without a pause.
# - server_tool_calls includes mcp_list_tools and mcp_call.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module MutinyBayRemoteMcp
  # The horn house at Mutiny Bay, inside Useless Bay, stores the blast log
  # on an Azure IoT Hub twin. The clerk looks the page up through OpenAI's
  # hosted Microsoft Learn connector, not the first-party MCP client.
  class LearnMcp
    INSTRUCTIONS = <<~TEXT.strip
      You are the horn clerk at Mutiny Bay.
      Use the Learn connector. Answer in two short sentences.
      The first sentence must contain the exact words Mutiny Bay and Alden.
      Repeat the Microsoft Learn page title.
      Do not invent a title.
    TEXT

    QUESTION = <<~TEXT.strip
      Thursday 15 October 2026, Mutiny Bay horn house.
      Docs: https://learn.microsoft.com/azure/iot-hub/iot-hub-devguide-device-twins
      The kelp-ledge gauge on Alden reports through Azure IoT Hub.
      Search Microsoft Learn for Azure IoT Hub device twins so the watch
      can store the 6.0 ft clearance on the twin. What is the page title?
    TEXT

    Result = Struct.new(
      :brief,
      :call_types,
      :call_names,
      :roles,
      :cost,
      keyword_init: true
    )

    def self.conduct
      configure
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_provider_tools(mcp: {
        name: "learn",
        url: "https://learn.microsoft.com/api/mcp",
        require_approval: "never",
        allowed_tools: ["microsoft_docs_search"]
      })
      brief = chat.ask(QUESTION)

      Result.new(
        brief: brief.content,
        call_types: brief.server_tool_calls.map(&:type),
        call_names: brief.server_tool_calls.map(&:name),
        roles: chat.messages.map(&:role),
        cost: brief.cost.total
      )
    end

    def self.open_chat
      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat
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
  Multivitamin::Cassettes.play(__dir__, "learn_mcp") do
    result = MutinyBayRemoteMcp::LearnMcp.conduct
  end

  puts result.brief
end
