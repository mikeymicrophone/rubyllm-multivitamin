# frozen_string_literal: true

# Tokens and cost · 08 · Cartagena tinto stream usage
#
# Teaches:
# - A streamed ask asks for usage. The counts land on the last chunk.
# - Earlier chunks, even one that already carries finish_reason, have
#   nil token counts.
# - The returned message's tokens and cost match that last chunk.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module CartagenaTintoStream
  # The tinto clerk on the Getsemaní corner dictates the steep time
  # over the stall phone and reads usage off the last chunk.
  class TintoStream
    INSTRUCTIONS = <<~TEXT.strip
      You are the tinto clerk on the Getsemaní corner in Cartagena.
      Answer with the steep card in one short sentence.
      Name 2.8 minutes and the cart La Popa.
      Use only the card in the question.
    TEXT

    CARD_QUESTION = <<~TEXT.strip
      Cartagena tinto steep card, Friday 16 October 2026, 09:05.
      City notes: https://www.cartagena.gov.co/
      Steep 2.8 minutes at 09:40, poured for the morning walk up Cerro de la Popa.
      The cart La Popa is working the plaza and needs that steep.
      Speak the steep for the log.
    TEXT

    Note = Struct.new(
      :content,
      :input_tokens,
      :output_tokens,
      :thinking_tokens,
      :finish_reason,
      :cost_total,
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
      message = chat.ask(CARD_QUESTION) do |chunk|
        notes << Note.new(
          content: chunk.content.to_s,
          input_tokens: chunk.tokens.input,
          output_tokens: chunk.tokens.output,
          thinking_tokens: chunk.tokens.thinking,
          finish_reason: chunk.finish_reason,
          cost_total: chunk.cost.total
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
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openrouter))
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openrouter)
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
  Multivitamin::Cassettes.play(__dir__, "tinto_stream") do
    result = CartagenaTintoStream::TintoStream.conduct
  end

  puts result.speech
  puts "tokens in=#{result.input_tokens} out=#{result.output_tokens} thinking=#{result.thinking_tokens} " \
       "cost=#{result.cost.inspect}"
end
