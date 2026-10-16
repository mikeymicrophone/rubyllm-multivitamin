# frozen_string_literal: true

# Rails integration · 05 · Medellín escalator-bay tool
#
# Teaches:
# - A tool on a persisted bay log writes ruby_llm_tool_calls.
# - The public reader is message.tool_calls, a RubyLLM::ToolCall.
# - The tool result is an application message with the tool role.
# - 2.1.1 has no application acts_as_tool_call macro.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/active_record"

module MedellinEscalatorBay
  class BayLog < ActiveRecord::Base
    self.table_name = "medellin_bay_logs"
    acts_as_chat messages: :bay_entries,
                 message_class: "MedellinEscalatorBay::BayEntry",
                 messages_foreign_key: :medellin_bay_log_id
  end

  class BayEntry < ActiveRecord::Base
    self.table_name = "medellin_bay_entries"
    acts_as_message chat: :bay_log,
                    chat_class: "MedellinEscalatorBay::BayLog",
                    chat_foreign_key: :medellin_bay_log_id
  end

  class BayLength < RubyLLM::Tool
    description "Reads the clear landing length of a numbered outdoor escalator bay in Comuna 13"

    def self.tool_name
      "bay_length"
    end

    parameter :bay, type: :integer, description: "Bay number on the Las Independencias escalator", required: true

    def execute(bay:)
      return "Bay 7 at Las Independencias is 42 m of clear landing." if bay.to_i == 7

      "No length card for bay #{bay}."
    end
  end

  class BayClerk
    INSTRUCTIONS = <<~TEXT.strip
      You are the escalator clerk for the outdoor stairs in Comuna 13, Medellín.
      Call bay_length once. Then answer in one sentence.
      Include the 42 m figure the tool returns. Name the comparsa La Candelaria.
    TEXT

    BAY_QUESTION = <<~TEXT.strip
      Wednesday 14 October 2026 at the Las Independencias escalator, Comuna 13, Medellín.
      Metro page: https://www.metrodemedellin.gov.co/
      The comparsa La Candelaria is 36 m of dancers and drums. Does bay 7 have room for them?
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
      log.with_tools(BayLength)
      log.with_tool_options(choice: BayLength)
      answer = log.ask(BAY_QUESTION)

      tool_entry = log.bay_entries.find { |entry| entry.role.to_s == "tool" }
      assistant_with_call = log.bay_entries.find(&:tool_call?)
      tool_call = assistant_with_call&.tool_calls&.values&.first

      Result.new(
        answer: answer.content,
        roles: log.bay_entries.map { |entry| entry.role.to_sym },
        tool_content: tool_entry&.content,
        tool_name: tool_call&.name,
        tool_call_count: RubyLLM::ActiveRecord::ToolCall.count,
        tool_call_class: RubyLLM::ActiveRecord::ToolCall.name,
        has_macro: ActiveRecord::Base.respond_to?(:acts_as_tool_call)
      )
    end

    def self.open_log
      choice = boot
      BayLog.create!(**choice)
    end

    def self.boot
      Multivitamin::ActiveRecordBoot.prepare!(
        chat_table: :medellin_bay_logs,
        message_table: :medellin_bay_entries,
        message_foreign_key: :medellin_bay_log_id
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
  Multivitamin::Cassettes.play(__dir__, "bay_tool") do
    result = MedellinEscalatorBay::BayClerk.conduct
  end

  puts result.answer
end
