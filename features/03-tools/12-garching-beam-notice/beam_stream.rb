# frozen_string_literal: true

# Tools · 12 · Garching beam-time notice
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
require_relative "../../../support/runtime"

module GarchingBeamNotice
  class BeamNotice < RubyLLM::Tool
    description "Reads one beam-time correction from the Garching folio"

    def self.tool_name
      "beam_notice"
    end

    parameter :notice, type: :string, description: "Notice number, such as 1842", required: true

    NOTICE = {
      "notice" => "1842",
      "proposal" => "18465",
      "correction" => "Move the muon telescope 0.2 hall west of the FRM-II shutter."
    }.freeze

    def execute(notice:)
      progress "Opening notice #{notice} in the Garching folio"
      NOTICE.merge("notice" => notice.to_s)
    end
  end

  class NoticeStream
    INSTRUCTIONS = <<~TEXT.strip
      You are the beam-time clerk correcting the Garching schedule.
      Call beam_notice with the notice number in the question.
      Then speak one sentence that includes the proposal number and the correction.
    TEXT

    NOTICE_QUESTION = <<~TEXT.strip
      Thursday 15 October 2026, beam-time desk at FRM-II, Garching.
      Reactor notes: https://www.frm2.tum.de/
      User office: https://mlz-garching.de/
      Read beam-time notice 1842 and speak the correction.
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
      chat.with_tools(BeamNotice)
      chat.with_tool_options(choice: BeamNotice)

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

    def self.configure = Multivitamin::Runtime.configure(provider: :openai, timeout: 180)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "beam_stream") do
    GarchingBeamNotice::NoticeStream.conduct
  end

  puts result.speech
end
