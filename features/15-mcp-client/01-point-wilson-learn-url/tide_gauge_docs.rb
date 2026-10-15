# frozen_string_literal: true

# MCP client · 01 · Point Wilson Learn URL
#
# Teaches:
# - A subclass of RubyLLM::MCP with url connects over Streamable HTTP.
# - with_mcp gives the chat that server's tools.
# - The model calls a server tool the way it calls a RubyLLM::Tool.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PointWilsonLearnUrl
  class MicrosoftLearnDocs < RubyLLM::MCP
    url "https://learn.microsoft.com/api/mcp"
    only :microsoft_docs_search
  end

  class TideGaugeDocs
    INSTRUCTIONS = <<~TEXT.strip
      You are the tide clerk at Point Wilson Light Station on Admiralty Inlet.
      Call microsoft_docs_search once for Azure IoT Hub device twins.
      Answer in two short sentences.
      Name the foghorn tender Alden.
      Repeat the document title the tool returned.
      Do not invent a title.
    TEXT

    GAUGE_QUESTION = <<~TEXT.strip
      Wednesday 14 October 2026, morning watch at Point Wilson.
      Tide reference: https://tidesandcurrents.noaa.gov/stationhome.html?id=9444900
      Docs: https://learn.microsoft.com/azure/iot-hub/iot-hub-devguide-device-twins
      The kelp-ledge gauge on the foghorn tender Alden reports through Azure IoT Hub.
      What Microsoft Learn page explains device twins, so the watch can store the 6.0 ft clearance on the twin?
    TEXT

    Result = Struct.new(
      :answer,
      :roles,
      :tool_names,
      :tool_content,
      :server_name,
      :connected,
      keyword_init: true
    )

    def self.conduct
      configure
      desk = MicrosoftLearnDocs.new
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_mcp(desk)
      chat.with_tool_options(choice: "microsoft_docs_search")

      answer = chat.ask(GAUGE_QUESTION)
      tool_messages = chat.messages.select { |message| message.role == :tool }

      Result.new(
        answer: answer.content,
        roles: chat.messages.map(&:role),
        tool_names: chat.tools.keys.map(&:to_s),
        tool_content: tool_messages.map(&:content).join("\n"),
        server_name: desk.name,
        connected: chat.mcp.microsoft_learn_docs.equal?(desk)
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
  Multivitamin::Cassettes.play(__dir__, "tide_gauge_docs") do
    result = PointWilsonLearnUrl::TideGaugeDocs.conduct
  end

  puts result.answer
end
