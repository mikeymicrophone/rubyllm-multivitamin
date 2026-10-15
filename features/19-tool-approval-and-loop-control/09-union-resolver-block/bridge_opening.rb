# frozen_string_literal: true

# Tool approval and loop control · 09 · Union resolver block
#
# Teaches:
# - requires_approval with a block reads the decision from the
#   application. The block is not run at class definition.
# - Return nil to keep waiting, true to execute. approve is not the
#   source of truth when a resolver is declared.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module UnionResolverBlock
  module BridgeLedger
    module_function

    def reset!
      @status = {}
      @consults = 0
    end

    def consults
      @consults
    end

    def status(tool_call_id)
      @consults += 1
      @status[tool_call_id]
    end

    def record(tool_call_id, decision)
      @status[tool_call_id] = decision
    end
  end

  class CanalBridgeOpening < RubyLLM::Tool
    description "Requests a Hood Canal Bridge lifting span opening at Union. Needs the bridge tender's ledger."

    def self.tool_name
      "canal_bridge_opening"
    end

    requires_approval { |tool_call| BridgeLedger.status(tool_call.id) }

    def self.reset!
      @opened = false
    end

    def self.opened?
      @opened == true
    end

    def execute
      self.class.instance_variable_set(:@opened, true)
      "Hood Canal Bridge opening granted at Union. Lifting span 14 minutes for the tug Salish Star."
    end
  end

  class BridgeTender
    INSTRUCTIONS = <<~TEXT.strip
      You are the bridge tender at Union on the Hood Canal Bridge.
      Call canal_bridge_opening once.
      After it runs, answer in one short sentence that names the tug and
      the opening length the tool returns.
    TEXT

    OPENING_QUESTION = <<~TEXT.strip
      Thursday 15 October 2026, morning lift at Union.
      Bridge notes: https://wsdot.wa.gov/travel/washington-state-ferries
      WSDOT page: https://wsdot.wa.gov/travel/bridges/hood-canal-bridge
      Open the lifting span for the tug Salish Star.
    TEXT

    Result = Struct.new(
      :awaiting,
      :consults_before_grant,
      :opened_before_grant,
      :opened_after,
      :answer,
      :tool_content,
      :roles,
      keyword_init: true
    )

    def self.conduct
      configure
      BridgeLedger.reset!
      CanalBridgeOpening.reset!

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_tools(CanalBridgeOpening)
      chat.with_tool_options(choice: CanalBridgeOpening)

      chat.ask(OPENING_QUESTION)
      pending = chat.pending_approvals.first
      awaiting = chat.awaiting_approval?
      consults_before_grant = BridgeLedger.consults
      opened_before_grant = CanalBridgeOpening.opened?

      BridgeLedger.record(pending.id, true) if pending
      answer = chat.complete
      tool_message = chat.messages.find { |message| message.role == :tool }

      Result.new(
        awaiting: awaiting,
        consults_before_grant: consults_before_grant,
        opened_before_grant: opened_before_grant,
        opened_after: CanalBridgeOpening.opened?,
        answer: answer&.content,
        tool_content: tool_message&.content,
        roles: chat.messages.map(&:role)
      )
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
  Multivitamin::Cassettes.play(__dir__, "bridge_opening") do
    result = UnionResolverBlock::BridgeTender.conduct
  end

  puts result.answer
end
