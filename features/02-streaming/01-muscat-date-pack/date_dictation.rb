# frozen_string_literal: true

# Streaming · 01 · Muscat date-pack dictation
#
# Teaches:
# - ask with a block yields a RubyLLM::Chunk, and Chunk is a Message.
# - The model id is chunk.model. Token counts stay nil until the usage chunk.
# - Reasoning arrives as chunks whose content is empty and whose thinking
#   holds the delta. The joined speech matches the returned message.

require_relative "../../../support/runtime"

module MuscatDatePack
  # The packing clerk at the Muttrah date loft reads the posted board into
  # the warehouse phone. The block hears every chunk; the returned message
  # is the note.
  class DateDictation
    INSTRUCTIONS = <<~TEXT.strip
      You are the packing clerk at the Muttrah date loft in Muscat.
      Dictate the board in two short sentences.
      Use only the board in the question.
      Name the packer Zahra, the time 10:46, the leftover 0.4 kg of Fardh,
      and the packed peak of 8.1 kg.
      Do not invent a kilogram figure.
    TEXT

    BOARD_QUESTION = <<~TEXT.strip
      Date-pack board posted for Wednesday 14 October 2026 at the Muttrah loft, Muscat.
      Loft notes: https://www.oman.om/
      Remaining 06:42, 0.4 kg of Fardh still on the sorting table.
      Packed peak 12:18, 8.1 kg.
      Evening 18:55, 2.6 kg sealed.
      Zahra's export carton needs 6.0 kg of Khalas to close a Gulf Air pallet and can leave at 10:46.
      The twins can weigh the leftover Fardh at 3.5 kg.
      Dictate that carton close for the incoming loft.
    TEXT

    ChunkNote = Struct.new(
      :content,
      :thinking,
      :model_id,
      :input_tokens,
      :output_tokens,
      :thinking_tokens,
      :finish_reason,
      :chunk,
      keyword_init: true
    )

    Result = Struct.new(
      :speech,
      :thinking,
      :model_id,
      :finish_reason,
      :input_tokens,
      :output_tokens,
      :thinking_tokens,
      :roles,
      :notes,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)

      notes = []
      message = chat.ask(BOARD_QUESTION) do |chunk|
        notes << ChunkNote.new(
          content: chunk.content,
          thinking: chunk.thinking&.text,
          model_id: chunk.model,
          input_tokens: chunk.tokens.input,
          output_tokens: chunk.tokens.output,
          thinking_tokens: chunk.tokens.thinking,
          finish_reason: chunk.finish_reason,
          chunk: chunk.is_a?(RubyLLM::Chunk)
        )
      end

      Result.new(
        speech: message.content,
        thinking: message.thinking&.text,
        model_id: message.model,
        finish_reason: message.finish_reason,
        input_tokens: message.tokens.input,
        output_tokens: message.tokens.output,
        thinking_tokens: message.tokens.thinking,
        roles: chat.messages.map(&:role),
        notes: notes
      )
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
    end

    def self.configure = Multivitamin::Runtime.configure(provider: :openai, timeout: 180)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "date_dictation") do
    MuscatDatePack::DateDictation.conduct
  end

  puts result.speech
end
