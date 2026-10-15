# frozen_string_literal: true

# MCP client · 11 · Port Angeles background tasks
#
# Teaches:
# - extension :tasks lets a server answer a long call with a task.
# - The chat pauses; awaiting_tasks? is true; complete checks once.
# - A second complete resumes when the ledger is ready.

require "logger"
require "rbconfig"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PortAngelesMcpTasks
  SERVER = File.expand_path("../stdio_server.rb", __dir__)
  PROFILE = File.expand_path("desk.json", __dir__)

  class PortAngelesNetLoftDesk < RubyLLM::MCP
    command RbConfig.ruby, SERVER, PROFILE
    extension :tasks
  end

  class TwineTask
    INSTRUCTIONS = <<~TEXT.strip
      You are the net loft clerk at Port Angeles.
      Call render_twine_ledger once.
      When the ledger is ready, answer in one sentence with the spool count.
      Name the loft.
    TEXT

    LEDGER_QUESTION = <<~TEXT.strip
      Wednesday 14 October 2026 at the Port Angeles net loft.
      Marina: https://www.portofpa.com/
      Render the twine ledger. How many spools of No. 18 tarred nylon are on the shelf?
    TEXT

    Result = Struct.new(
      :answer,
      :roles,
      :tool_content,
      :awaited,
      :status_after_first,
      :status_message,
      :done_after_second,
      keyword_init: true
    )

    def self.conduct
      configure
      desk = PortAngelesNetLoftDesk.new
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_mcp(desk)
      chat.with_tool_options(choice: "render_twine_ledger")
      chat.ask(LEDGER_QUESTION)
      awaited = chat.awaiting_tasks?
      task = chat.pending_tasks.first
      chat.complete
      status_after_first = task.status
      status_message = task.status_message
      answer = chat.complete

      Result.new(
        answer: answer.content,
        roles: chat.messages.map(&:role),
        tool_content: chat.messages.find { |message| message.role == :tool }&.content,
        awaited: awaited,
        status_after_first: status_after_first,
        status_message: status_message,
        done_after_second: !chat.awaiting_tasks?
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
  Multivitamin::Cassettes.play(__dir__, "twine_task") do
    result = PortAngelesMcpTasks::TwineTask.conduct
  end

  puts result.answer
end
