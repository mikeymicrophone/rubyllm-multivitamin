# frozen_string_literal: true

# Streaming · 06 · Alden radio check
#
# Teaches:
# - A streamed ask asks for usage, and the counts land on the last chunk.
# - Earlier chunks, including one that already carries finish_reason, have
#   nil token counts.
# - The returned message's tokens match that last chunk.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AldenRadioCheck
  # The foghorn tender Alden calls Point Wilson on the working channel.
  # The watch logs the check, then reads the token counts off the last chunk.
  class RadioCheck
    INSTRUCTIONS = <<~TEXT.strip
      You are the radio watch at Point Wilson Light Station.
      Answer with the radio check in one short sentence.
      Name the tender Alden and channel 66.
      Use only the check in the question.
    TEXT

    CHECK_QUESTION = <<~TEXT.strip
      Radio check Wednesday 14 October 2026, 06:10.
      The foghorn tender Alden calls Point Wilson.
      Working channel 66. The call is loud and clear.
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
      RubyLLM.chat(
        model: Multivitamin::Models::CHAT,
        provider: :openrouter,
        assume_model_exists: true
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        config.openrouter_api_key = ENV.fetch("OPENROUTER_API_KEY")
        config.openrouter_app_url = "https://github.com/mikeymicrophone/rubyllm-multivitamin"
        config.openrouter_app_name = "RubyLLM Multivitamin"
        # Chat Completions emits a developer role unless this is set.
        # OpenRouter expects system. The flag is shared with OpenAI's formatter.
        config.openai_use_system_role = true
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
  Multivitamin::Cassettes.play(__dir__, "radio_check") do
    result = AldenRadioCheck::RadioCheck.conduct
  end

  puts result.speech
  puts "tokens in=#{result.input_tokens} out=#{result.output_tokens} thinking=#{result.thinking_tokens}"
end
