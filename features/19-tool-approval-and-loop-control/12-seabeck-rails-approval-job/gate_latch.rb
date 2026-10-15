# frozen_string_literal: true

# Tool approval and loop control · 12 · Seabeck Rails approval job
#
# Teaches:
# - acts_as_chat persists an approval-gated call. complete parks the
#   marina desk until a decision is on the tool-call row.
# - approve writes approval "approved". find on the agent class restores
#   the tools, then complete executes from the saved decision.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/active_record"

module SeabeckRailsApprovalJob
  class MarinaLog < ActiveRecord::Base
    self.table_name = "seabeck_marina_logs"
    acts_as_chat messages: :gate_entries,
                 message_class: "SeabeckRailsApprovalJob::GateEntry",
                 messages_foreign_key: :seabeck_marina_log_id
  end

  class GateEntry < ActiveRecord::Base
    self.table_name = "seabeck_gate_entries"
    acts_as_message chat: :marina_log,
                    chat_class: "SeabeckRailsApprovalJob::MarinaLog",
                    chat_foreign_key: :seabeck_marina_log_id
  end

  class GateLatch < RubyLLM::Tool
    description "Opens the Seabeck marina gate for a named boat. Needs the harbor master's latch."

    def self.tool_name
      "gate_latch"
    end

    requires_approval

    parameter :boat, type: :string, description: "Boat waiting on the float, such as the seiner Elwha", required: true

    def self.reset!
      @opened_for = nil
    end

    def self.opened_for
      @opened_for
    end

    def execute(boat:)
      self.class.instance_variable_set(:@opened_for, boat.to_s)
      "Seabeck marina gate opened for the #{boat}. Flood 1.6 kn on the Seabeck Bay staff."
    end
  end

  class HarborMaster < RubyLLM::Agent
    chat_model MarinaLog
    model Multivitamin::Models::OPENAI_CHAT, provider: :openai
    tools GateLatch
    tool_options choice: GateLatch
    temperature 0.2

    instructions <<~TEXT.strip
      You are the harbor master at Seabeck marina.
      Call gate_latch for the boat in the question.
      After it runs, answer in one short sentence that names the seiner
      and the flood the latch returns.
    TEXT
  end

  class GateJob
    GATE_QUESTION = <<~TEXT.strip
      Thursday 15 October 2026, flood watch at Seabeck marina.
      Bay notes: https://www.charts.noaa.gov/
      Open the marina gate for the seiner Elwha.
    TEXT

    Result = Struct.new(
      :awaiting,
      :approval_before,
      :opened_before,
      :same_id,
      :approval_after,
      :opened_after,
      :answer,
      :roles,
      :tool_call_count,
      keyword_init: true
    )

    def self.conduct
      GateLatch.reset!
      log = open_log
      Multivitamin::Models.quiet_thinking(log, provider: :openai)
      log.ask_later(GATE_QUESTION)
      log.complete

      pending = log.pending_approvals.first
      awaiting = log.awaiting_approval?
      approval_before = pending&.approval
      opened_before = GateLatch.opened_for

      found = HarborMaster.find(log.id)
      found.approve(found.pending_approvals.first)
      answer = found.complete
      stored = RubyLLM::ActiveRecord::ToolCall.first

      Result.new(
        awaiting: awaiting,
        approval_before: approval_before,
        opened_before: opened_before,
        same_id: found.id == log.id,
        approval_after: stored&.approval,
        opened_after: GateLatch.opened_for,
        answer: answer&.content,
        roles: found.gate_entries.map { |entry| entry.role.to_sym },
        tool_call_count: RubyLLM::ActiveRecord::ToolCall.count
      )
    end

    def self.open_log
      chosen = boot
      kwargs = { provider: chosen[:provider] }
      kwargs[:assume_model_exists] = true if chosen[:assume_model_exists]
      HarborMaster.create!(model: chosen[:model], **kwargs)
    end

    def self.boot
      Multivitamin::ActiveRecordBoot.prepare!(
        chat_table: :seabeck_marina_logs,
        message_table: :seabeck_gate_entries,
        message_foreign_key: :seabeck_marina_log_id
      )
      chosen = Multivitamin::Models.chat(provider: :openai)
      Multivitamin::ActiveRecordBoot.seed_model(model_id: chosen[:model], provider: chosen[:provider])
      configure
      chosen
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
  Multivitamin::Cassettes.play(__dir__, "gate_latch") do
    result = SeabeckRailsApprovalJob::GateJob.conduct
  end

  puts result.answer
end
