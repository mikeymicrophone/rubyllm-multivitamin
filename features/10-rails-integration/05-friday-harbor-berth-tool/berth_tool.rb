# frozen_string_literal: true

# Rails integration · 05 · Friday Harbor berth tool
#
# Teaches:
# - A tool on a persisted berth log writes ruby_llm_tool_calls.
# - The public reader is message.tool_calls, a RubyLLM::ToolCall.
# - The tool result is an application message with the tool role.
# - 2.1.1 has no application acts_as_tool_call macro.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/active_record"

module FridayHarborBerthTool
  class BerthLog < ActiveRecord::Base
    self.table_name = "friday_harbor_berth_logs"
    acts_as_chat messages: :berth_entries,
                 message_class: "FridayHarborBerthTool::BerthEntry",
                 messages_foreign_key: :friday_harbor_berth_log_id
  end

  class BerthEntry < ActiveRecord::Base
    self.table_name = "friday_harbor_berth_entries"
    acts_as_message chat: :berth_log,
                    chat_class: "FridayHarborBerthTool::BerthLog",
                    chat_foreign_key: :friday_harbor_berth_log_id
  end

  class BerthLength < RubyLLM::Tool
    description "Reads the clear fender length of a numbered berth at Friday Harbor"

    def self.tool_name
      "berth_length"
    end

    parameter :berth, type: :integer, description: "Berth number on the Friday Harbor float", required: true

    def execute(berth:)
      return "Berth 7 at Friday Harbor is 54 ft of clear fender." if berth.to_i == 7

      "No length card for berth #{berth}."
    end
  end

  class BerthClerk
    INSTRUCTIONS = <<~TEXT.strip
      You are the berth clerk at Friday Harbor.
      Call berth_length once. Then answer in one sentence.
      Include the 54 ft figure the tool returns. Name the seiner Kulshan.
    TEXT

    BERTH_QUESTION = <<~TEXT.strip
      Wednesday 14 October 2026 at the Friday Harbor float.
      Marina office: https://www.portfridayharbor.org/
      The seiner Kulshan is 48 ft. Does berth 7 have room for her?
    TEXT

    Result = Struct.new(
      :answer,
      :roles,
      :tool_content,
      :tool_name,
      :tool_call_count,
      :tool_call_class,
      :has_macro,
      keyword_init: true
    )

    def self.conduct
      log = open_log
      log.with_instructions(INSTRUCTIONS)
      log.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(log, provider: :openai)
      log.with_tools(BerthLength)
      log.with_tool_options(choice: BerthLength)
      answer = log.ask(BERTH_QUESTION)

      tool_entry = log.berth_entries.find { |entry| entry.role.to_s == "tool" }
      assistant_with_call = log.berth_entries.find(&:tool_call?)
      tool_call = assistant_with_call&.tool_calls&.values&.first

      Result.new(
        answer: answer.content,
        roles: log.berth_entries.map { |entry| entry.role.to_sym },
        tool_content: tool_entry&.content,
        tool_name: tool_call&.name,
        tool_call_count: RubyLLM::ActiveRecord::ToolCall.count,
        tool_call_class: RubyLLM::ActiveRecord::ToolCall.name,
        has_macro: ActiveRecord::Base.respond_to?(:acts_as_tool_call)
      )
    end

    def self.open_log
      choice = boot
      BerthLog.create!(**choice)
    end

    def self.boot
      Multivitamin::ActiveRecordBoot.prepare!(
        chat_table: :friday_harbor_berth_logs,
        message_table: :friday_harbor_berth_entries,
        message_foreign_key: :friday_harbor_berth_log_id
      )
      choice = Multivitamin::Models.chat(provider: :openai)
      Multivitamin::ActiveRecordBoot.seed_model(model_id: choice[:model], provider: choice[:provider])
      configure
      choice
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
  Multivitamin::Cassettes.play(__dir__, "berth_tool") do
    result = FridayHarborBerthTool::BerthClerk.conduct
  end

  puts result.answer
end
