# frozen_string_literal: true

# Streaming · 08 · Fez tannery pit halt
#
# Teaches:
# - chat.cancel marks the stream, and the next chunk checkpoint raises
#   RubyLLM::CancelledError.
# - CancelledError inherits StandardError, not RubyLLM::Error.
# - The partial call stays with the master. The assistant turn is not appended.

require_relative "../../../support/runtime"

module FezTanneryHalt
  # The pit caller at Chouara reads four lime-pit strengths. The master
  # stops the call after two spoken pieces, before the rest of the round
  # is logged.
  class TanneryHalt
    INSTRUCTIONS = <<~TEXT.strip
      You are the pit caller at Chouara Tannery in Fez.
      Call the four pit readings in order, one short sentence each.
      Use only the round on the card.
    TEXT

    CAST_QUESTION = <<~TEXT.strip
      Lime-pit round Wednesday 14 October 2026, Chouara Tannery, Fez.
      Medina notes: https://whc.unesco.org/en/list/170/
      First call: six Baumé.
      Second call: five Baumé.
      Third call: by the mark, five.
      Fourth call: four Baumé, and the master holds the hides.
      Call the four readings.
    TEXT

    Result = Struct.new(:spoken, :error, :roles, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)

      spoken = []
      error = nil
      begin
        chat.ask(CAST_QUESTION) do |chunk|
          piece = chunk.content.to_s
          next if piece.empty?

          spoken << piece
          chat.cancel if spoken.size == 2
        end
      rescue RubyLLM::CancelledError => raised
        error = raised
      end

      Result.new(spoken: spoken, error: error, roles: chat.messages.map(&:role))
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
    end

    def self.configure = Multivitamin::Runtime.configure(provider: :openai, timeout: 180)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "tannery_halt") do
    FezTanneryHalt::TanneryHalt.conduct
  end

  puts result.spoken.join
  puts
  puts result.error.class
end
