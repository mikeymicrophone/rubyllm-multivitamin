# frozen_string_literal: true

# Streaming · 06 · Kigali drone corridor check
#
# Teaches:
# - A streamed ask lands token counts on the last chunk.
# - Earlier chunks have nil token counts. On Chat Completions one of those
#   earlier chunks can already carry finish_reason. On OpenAI Responses the
#   finish reason typically arrives with the usage chunk.
# - The returned message's tokens match that last chunk.

require_relative "../../../support/runtime"

module KigaliCorridorCheck
  # The corridor dispatcher Amahoro calls Kigali International on the
  # working channel. The tower logs the check, then reads the token counts
  # off the last chunk.
  class CorridorCheck
    INSTRUCTIONS = <<~TEXT.strip
      You are the tower watch at Kigali International Airport.
      Answer with the corridor check in one short sentence.
      Name the dispatcher Amahoro and corridor 66.
      Use only the check in the question.
    TEXT

    CHECK_QUESTION = <<~TEXT.strip
      Drone corridor check Wednesday 14 October 2026, 06:10.
      The medical dispatcher Amahoro calls Kigali International.
      Working corridor 66. The call is loud and clear.
      Speak the check for the log.
    TEXT

    Note = Struct.new(
      :content,
      :input_tokens,
      :output_tokens,
      :thinking_tokens,
      :finish_reason,
      keyword_init: true
    )

    Result = Struct.new(
      :speech,
      :notes,
      :input_tokens,
      :output_tokens,
      :thinking_tokens,
      :finish_reason,
      :cost,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)

      notes = []
      message = chat.ask(CHECK_QUESTION) do |chunk|
        notes << Note.new(
          content: chunk.content.to_s,
          input_tokens: chunk.tokens.input,
          output_tokens: chunk.tokens.output,
          thinking_tokens: chunk.tokens.thinking,
          finish_reason: chunk.finish_reason
        )
      end

      Result.new(
        speech: message.content,
        notes: notes,
        input_tokens: message.tokens.input,
        output_tokens: message.tokens.output,
        thinking_tokens: message.tokens.thinking,
        finish_reason: message.finish_reason,
        cost: message.cost.total
      )
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
    end

    def self.configure = Multivitamin::Runtime.configure(provider: :openai, timeout: 180)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "corridor_check") do
    KigaliCorridorCheck::CorridorCheck.conduct
  end

  puts result.speech
  puts "tokens in=#{result.input_tokens} out=#{result.output_tokens} thinking=#{result.thinking_tokens}"
end
