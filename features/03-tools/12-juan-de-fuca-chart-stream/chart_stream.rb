# frozen_string_literal: true

# Tools · 12 · Juan de Fuca chart stream
#
# Teaches:
# - A streamed tool call yields argument strings on the chunks.
# - before_tool_call receives the finished arguments as a Hash.
# - after_tool_result receives the Ruby return. A Hash becomes JSON only
#   on the tool message.
# - after_tool_progress receives Tool#progress.
# - chat.messages keeps the assistant tool_calls and the :tool reply,
#   and Message#tool_results joins them.

require "json"
require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module JuanDeFucaChartStream
  class ChartNotice < RubyLLM::Tool
    description "Reads one chart correction from the Juan de Fuca folio"

    def self.tool_name
      "chart_notice"
    end

    parameter :notice, type: :string, description: "Notice number, such as 1842", required: true

    NOTICE = {
      "notice" => "1842",
      "chart" => "18465",
      "correction" => "Move the bell buoy symbol 0.2 mile west of Ediz Hook."
    }.freeze

    def execute(notice:)
      progress "Opening notice #{notice} in the Juan de Fuca folio"
      NOTICE.merge("notice" => notice.to_s)
    end
  end

  class NoticeStream
    INSTRUCTIONS = <<~TEXT.strip
      You are the mate correcting the Juan de Fuca chart.
      Call chart_notice with the notice number in the question.
      Then speak one sentence that includes the chart number and the correction.
    TEXT

    NOTICE_QUESTION = <<~TEXT.strip
      Wednesday 14 October 2026, chart desk for the Strait of Juan de Fuca.
      Chart catalog: https://www.nauticalcharts.noaa.gov/
      Notice desk: https://www.navcen.uscg.gov/
      Read chart notice 1842 and speak the correction.
    TEXT

    Result = Struct.new(
      :speech,
      :pieces,
      :roles,
      :fragments,
      :tool_arguments,
      :callback_result,
      :progress_notes,
      :tool_content,
      :tool_call_id,
      :linked_content,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_tools(ChartNotice)
      chat.with_tool_options(choice: ChartNotice)

      tool_arguments = nil
      callback_result = nil
      progress_notes = []
      chat.before_tool_call { |tool_call| tool_arguments = tool_call.arguments }
      chat.after_tool_result { |result| callback_result = result }
      chat.after_tool_progress { |_tool_call, progress| progress_notes << progress.message }

      pieces = []
      fragments = []
      message = chat.ask(NOTICE_QUESTION) do |chunk|
        if chunk.tool_call?
          chunk.tool_calls.each_value do |call|
            fragments << [call.name, call.arguments]
          end
        end

        piece = chunk.content.to_s
        pieces << piece unless piece.empty?
      end

      tool_turn = chat.messages.find(&:tool_call?)
      tool_message = chat.messages.find(&:tool_result?)

      Result.new(
        speech: message.content,
        pieces: pieces,
        roles: chat.messages.map(&:role),
        fragments: fragments,
        tool_arguments: tool_arguments,
        callback_result: callback_result,
        progress_notes: progress_notes,
        tool_content: tool_message&.content,
        tool_call_id: tool_message&.tool_call_id,
        linked_content: tool_turn&.tool_results&.map(&:content)
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
  Multivitamin::Cassettes.play(__dir__, "chart_stream") do
    result = JuanDeFucaChartStream::NoticeStream.conduct
  end

  puts result.speech
end
