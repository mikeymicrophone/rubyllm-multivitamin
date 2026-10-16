# frozen_string_literal: true

# Streaming · 13 · Kiruna skip-hoist relief
#
# Teaches:
# - A streamed tool call arrives as partial argument strings on the chunks.
# - before_tool_call receives the finished call. The chunk is not where the
#   tool runs.
# - After the tool, the spoken relief can be cancelled on a later chunk.

require_relative "../../../support/runtime"

module KirunaSkipRelief
  # The posted skip card is not in the question. The relief has to read it
  # through the tool, then the outgoing hoist watch starts to speak and is
  # stopped.
  class PostedSkipCard < RubyLLM::Tool
    description "Reads the skip-hoist card posted at Kiruna mine"

    def execute(mine:)
      "Kiruna skip card for #{mine}. Cycle 2.5 seconds, rest 17.5 seconds. Accumulator 92 bar."
    end
  end

  class SkipRelief
    INSTRUCTIONS = <<~TEXT.strip
      You are the outgoing skip-hoist watch at LKAB Kiruna.
      Call the posted skip card tool for the mine in the question.
      Then speak one short sentence for the relief that includes the cycle and the accumulator.
    TEXT

    RELIEF_QUESTION = <<~TEXT.strip
      The relief is taking the skip watch at Kiruna on Wednesday 14 October 2026.
      Mine notes: https://lkab.com/en/what-we-do/our-mines/kiruna-mine/
      Read the posted skip card for Kiruna and start the spoken relief.
    TEXT

    Result = Struct.new(
      :spoken,
      :error,
      :roles,
      :tool_content,
      :tool_arguments,
      :argument_fragments,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_tools(PostedSkipCard)
      chat.with_tool_options(choice: PostedSkipCard)

      tool_arguments = nil
      chat.before_tool_call { |tool_call| tool_arguments = tool_call.arguments }

      spoken = []
      fragments = []
      error = nil
      begin
        chat.ask(RELIEF_QUESTION) do |chunk|
          if chunk.tool_call?
            chunk.tool_calls.each_value do |call|
              fragments << [call.name, call.arguments]
            end
          end

          piece = chunk.content.to_s
          next if piece.empty?

          spoken << piece
          chat.cancel if tool_arguments && spoken.size == 2
        end
      rescue RubyLLM::CancelledError => raised
        error = raised
      end

      tool_message = chat.messages.find { |message| message.role == :tool }

      Result.new(
        spoken: spoken,
        error: error,
        roles: chat.messages.map(&:role),
        tool_content: tool_message&.content,
        tool_arguments: tool_arguments,
        argument_fragments: fragments
      )
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
    end

    def self.configure = Multivitamin::Runtime.configure(provider: :openai, timeout: 180)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "skip_relief") do
    KirunaSkipRelief::SkipRelief.conduct
  end

  puts result.spoken.join
  puts
  puts result.tool_content
  puts result.error.class
end
