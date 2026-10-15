# frozen_string_literal: true

# MCP client · 03 · Cape Disappointment only/except/prefix
#
# Teaches:
# - only keeps the server tools the model may see.
# - except hides a named tool even when only listed it.
# - prefix rewrites those names so two desks can share a chat.

require "logger"
require "rbconfig"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module CapeDisappointmentOnlyPrefix
  SERVER = File.expand_path("../stdio_server.rb", __dir__)
  PROFILE = File.expand_path("desk.json", __dir__)

  class CapeHornDesk < RubyLLM::MCP
    command RbConfig.ruby, SERVER, PROFILE
    only :posted_horn_card, :posted_tide_board, :silence_horn
    except :silence_horn
    prefix :cape
  end

  class HornPrefix
    INSTRUCTIONS = <<~TEXT.strip
      You are the horn clerk at Cape Disappointment.
      Call cape_posted_horn_card once. Do not call a tide tool.
      Answer in one sentence. Include the blast length the card returns.
      Name the tender Peacock.
    TEXT

    HORN_QUESTION = <<~TEXT.strip
      Wednesday 14 October 2026, morning watch at Cape Disappointment.
      Station: https://www.nps.gov/lewi/learn/historyculture/cape-disappointment.htm
      The bar tender Peacock is standing off the horn house. Is the horn running, and what is the blast?
    TEXT

    Result = Struct.new(:answer, :roles, :tool_names, :tool_content, keyword_init: true)

    def self.conduct
      configure
      desk = CapeHornDesk.new
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_mcp(desk)
      chat.with_tool_options(choice: "cape_posted_horn_card")

      answer = chat.ask(HORN_QUESTION)
      tool_message = chat.messages.find { |message| message.role == :tool }

      Result.new(
        answer: answer.content,
        roles: chat.messages.map(&:role),
        tool_names: chat.tools.keys.map(&:to_s),
        tool_content: tool_message&.content
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
  Multivitamin::Cassettes.play(__dir__, "horn_prefix") do
    result = CapeDisappointmentOnlyPrefix::HornPrefix.conduct
  end

  puts result.answer
end
