# frozen_string_literal: true

# MCP client · 10 · Port Townsend input-request pause
#
# Teaches:
# - A server can stop a tool call to ask the watch a form question.
# - A request no callback answers pauses the chat, the way approvals do.
# - answer then complete sends the slip and finishes the call.

require "logger"
require "rbconfig"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PortTownsendMcpInput
  SERVER = File.expand_path("../stdio_server.rb", __dir__)
  PROFILE = File.expand_path("desk.json", __dir__)

  class PortTownsendSlipDesk < RubyLLM::MCP
    command RbConfig.ruby, SERVER, PROFILE
  end

  class SlipPause
    INSTRUCTIONS = <<~TEXT.strip
      You are the slip clerk at Port Townsend.
      Call choose_ferry_slip once.
      After the desk answers, speak one sentence that names the Chetzemoka and the slip.
    TEXT

    SLIP_QUESTION = <<~TEXT.strip
      Wednesday 14 October 2026 at the Port Townsend ferry terminal.
      Terminal: https://wsdot.wa.gov/travel/washington-state-ferries
      Which slip does the Chetzemoka take while the wind is up off Point Hudson?
    TEXT

    Result = Struct.new(
      :answer,
      :roles,
      :tool_content,
      :awaited,
      :message,
      :choices,
      keyword_init: true
    )

    def self.conduct
      configure
      desk = PortTownsendSlipDesk.new
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_mcp(desk)
      chat.with_tool_options(choice: "choose_ferry_slip")
      chat.ask(SLIP_QUESTION)
      awaited = chat.awaiting_input?
      request = chat.pending_inputs.first
      chat.answer(request, slip: "A")
      answer = chat.complete
      tool_message = chat.messages.find { |message| message.role == :tool }

      Result.new(
        answer: answer.content,
        roles: chat.messages.map(&:role),
        tool_content: tool_message&.content,
        awaited: awaited,
        message: request.message,
        choices: request.fields.first.choices
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
  Multivitamin::Cassettes.play(__dir__, "slip_pause") do
    result = PortTownsendMcpInput::SlipPause.conduct
  end

  puts result.answer
end
