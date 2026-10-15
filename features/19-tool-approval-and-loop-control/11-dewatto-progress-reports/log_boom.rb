# frozen_string_literal: true

# Tool approval and loop control · 11 · Dewatto progress reports
#
# Teaches:
# - progress inside execute reports what a slow count is doing.
# - after_tool_progress receives the tool call and a Progress, including
#   value, total, and fraction.
# - before_tool_call and after_tool_result still fire around execute.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module DewattoProgressReports
  class LogBoomCount < RubyLLM::Tool
    description "Counts the log booms on the Dewatto reach"

    def self.tool_name
      "log_boom_count"
    end

    BOOMS = [
      "Boom 12-A alder",
      "Boom 12-B cedar",
      "Boom 12-C fir",
      "Boom 12-D hemlock"
    ].freeze

    CARD = <<~TEXT.strip
      Dewatto reach boom count, Thursday 15 October 2026.
      Four booms: 12-A alder, 12-B cedar, 12-C fir, 12-D hemlock. Stick count 186.
    TEXT

    def execute
      BOOMS.each_with_index do |boom, index|
        progress "Counting #{boom} on the Dewatto reach", value: index + 1, total: BOOMS.size
      end
      CARD
    end
  end

  class BoomClerk
    INSTRUCTIONS = <<~TEXT.strip
      You are the boom clerk at Dewatto.
      Call log_boom_count once.
      Answer in one short sentence that names the stick count and the
      last boom the card lists.
    TEXT

    COUNT_QUESTION = <<~TEXT.strip
      Thursday 15 October 2026, boom round on the Dewatto reach.
      Canal notes: https://www.charts.noaa.gov/
      Count the log booms and post the stick total.
    TEXT

    Result = Struct.new(
      :answer,
      :tool_arguments,
      :callback_result,
      :progress_notes,
      :fractions,
      :values,
      :totals,
      :tool_content,
      :roles,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_tools(LogBoomCount)
      chat.with_tool_options(choice: LogBoomCount)

      tool_arguments = nil
      callback_result = nil
      progress_notes = []
      fractions = []
      values = []
      totals = []
      chat.before_tool_call { |tool_call| tool_arguments = tool_call.arguments }
      chat.after_tool_result { |result| callback_result = result }
      chat.after_tool_progress do |_tool_call, progress|
        progress_notes << progress.message
        fractions << progress.fraction
        values << progress.value
        totals << progress.total
      end

      answer = chat.ask(COUNT_QUESTION)
      tool_message = chat.messages.find { |message| message.role == :tool }

      Result.new(
        answer: answer.content,
        tool_arguments: tool_arguments,
        callback_result: callback_result,
        progress_notes: progress_notes,
        fractions: fractions,
        values: values,
        totals: totals,
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
  Multivitamin::Cassettes.play(__dir__, "log_boom") do
    result = DewattoProgressReports::BoomClerk.conduct
  end

  puts result.answer
end
